#import "NUANotificationRepository.h"
#import <FrontBoardServices/FrontBoardServices.h>
#import <SpringBoard/SpringBoard-Umbrella.h>

@interface NUANotificationRepository () {
    NSHashTable<id<NUANotificationsObserver>> *_observers;
    dispatch_queue_t _queue;
    dispatch_queue_t _callOutQueue;
}

@property (strong, nonatomic) NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, NUACoalescedNotification *> *> *notificationByIdentifier;

@end

@implementation NUANotificationRepository

#pragma mark - Class Methods

+ (NSSet<NSString *> *)_excludedSectionIdentifiers {
    // Set of exculded notification identifiers
    return [NSSet setWithArray:@[@"com.apple.donotdisturb", @"com.apple.Passbook", @"com.apple.cmas"]];
}

#pragma mark - Init

+ (instancetype)defaultRepository {
    static NUANotificationRepository *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // Set defaults
        _observers = [NSHashTable weakObjectsHashTable];
        _notificationByIdentifier = [NSMutableDictionary dictionary];

        // Create threads
        dispatch_queue_attr_t attributes = dispatch_queue_attr_make_with_autorelease_frequency(DISPATCH_QUEUE_SERIAL, DISPATCH_AUTORELEASE_FREQUENCY_WORK_ITEM);
        dispatch_queue_attr_t mainAttributes = dispatch_queue_attr_make_with_qos_class(attributes, QOS_CLASS_USER_INITIATED, 0);
        _queue = dispatch_queue_create("com.shade.nougat.notifications-provider", mainAttributes);

        dispatch_queue_attr_t calloutAttributes = dispatch_queue_attr_make_with_qos_class(attributes, QOS_CLASS_USER_INTERACTIVE, 0);
        _callOutQueue = dispatch_queue_create("com.shade.nougat.notifications-provider.call-out", calloutAttributes);

        // Register as destination
        SBNCNotificationDispatcher *notificationDispatcher = ((SpringBoard *)[UIApplication sharedApplication]).notificationDispatcher; 
        NCNotificationDispatcher *dispatcher = notificationDispatcher.dispatcher;
        [dispatcher registerDestination:self];
        [dispatcher setDestination:self enabled:YES];
    }

    return self;
}

#pragma mark - Properties

- (NSSet<NUACoalescedNotification *> *)notifications {
    // Dispatch onto queue
    __block NSMutableSet<NUACoalescedNotification *> *notifications = [NSMutableSet set];
    dispatch_sync(_queue, ^{
        // Map down dictionary into array
        for (NSDictionary<NSString *, NUACoalescedNotification *> *notificationGroups in self.notificationByIdentifier.allValues) {
            NSArray<NUACoalescedNotification *> *notificationThreads = notificationGroups.allValues;
            [notifications addObjectsFromArray:notificationThreads];
        }
    });

    return [notifications copy];
}

#pragma mark -  NCNotificationDestination

- (NSString *)identifier {
    return @"BulletinDestinationNotificationShade";
}

- (BOOL)canReceiveNotificationRequest:(NCNotificationRequest *)request {
    // Basically always
    return YES;
}

- (void)postNotificationRequest:(NCNotificationRequest *)request forCoalescedNotification:(NCCoalescedNotification *)coalescedNotification {
    // Ensure on queue, pass on
    dispatch_sync(_queue, ^{
        [self insertNotificationRequest:request forCoalescedNotification:coalescedNotification];
    });
}

- (void)modifyNotificationRequest:(NCNotificationRequest *)request forCoalescedNotification:(NCCoalescedNotification *)coalescedNotification {
    // Ensure on queue, pass on
    dispatch_sync(_queue, ^{
        [self insertNotificationRequest:request forCoalescedNotification:coalescedNotification];
    });
}

- (void)withdrawNotificationRequest:(NCNotificationRequest *)request forCoalescedNotification:(NCCoalescedNotification *)coalescedNotification {
    // Ensure on queue, pass on
    dispatch_sync(_queue, ^{
        [self removeNotificationRequest:request forCoalescedNotification:coalescedNotification];
    });
}

- (void)postNotificationRequest:(NCNotificationRequest *)request {
    // Ensure on queue, pass on
    dispatch_sync(_queue, ^{
        [self insertNotificationRequest:request forCoalescedNotification:nil];
    });
}

- (void)modifyNotificationRequest:(NCNotificationRequest *)request {
    // Ensure on queue, pass on
    dispatch_sync(_queue, ^{
        [self insertNotificationRequest:request forCoalescedNotification:nil];
    });
}

- (void)withdrawNotificationRequest:(NCNotificationRequest *)request {
    // Ensure on queue, pass on
    dispatch_sync(_queue, ^{
        [self removeNotificationRequest:request forCoalescedNotification:nil];
    });
}

#pragma mark - Notification Launching

- (void)executeAction:(NCNotificationAction *)action forNotificationRequest:(NCNotificationRequest *)request {
    // Find the proper method
    if ([self.delegate respondsToSelector:@selector(destination:executeAction:forNotificationRequest:requestAuthentication:withParameters:completion:)]) {
        // iOS 11+
        [self.delegate destination:self executeAction:action forNotificationRequest:request requestAuthentication:YES withParameters:@{} completion:nil];
    } else {
        // iOS 10
        [self.delegate destination:self executeAction:action forNotificationRequest:request withParameters:@{} completion:nil];
    }
}

- (BSServiceConnectionEndpoint *)endpoint {
    if (!NSClassFromString(@"BSServiceConnectionEndpoint")) {
        // Doesn't apply
        return nil;
    }

    NSString *serviceName = [FBSOpenApplicationService serviceName];
    return [NSClassFromString(@"BSServiceConnectionEndpoint") endpointForMachName:@"com.apple.frontboard.systemappservices" service:serviceName instance:nil];
}

#pragma mark - Observers

- (void)addObserver:(id<NUANotificationsObserver>)observer {
    if ([_observers containsObject:observer]) {
        return;
    }

    [_observers addObject:observer];
}

- (void)removeObserver:(id<NUANotificationsObserver>)observer {
    if (![_observers containsObject:observer]) {
        return;
    }

    [_observers removeObject:observer];
}

- (void)notifyObserversUsingBlock:(NUANotificationsObserverHandler)handler {
    // Ensure on queue
    dispatch_assert_queue(_queue);

    // Dispatch on calloutQueue
    dispatch_async(_callOutQueue, ^{
        NSArray<id<NUANotificationsObserver>> *observers = [_observers.allObjects copy];
        for (id<NUANotificationsObserver> observer in observers) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(observer);
            });
        }
    });
}

#pragma mark - Notification Management

- (BOOL)containsThreadForRequest:(NCNotificationRequest *)request {
    // Ensure on queue
    dispatch_assert_queue(_queue);

    // Access notifications asynchronously
    BOOL containsSection = [self.notificationByIdentifier.allKeys containsObject:request.sectionIdentifier];
    if (!containsSection) {
        // Doesn't even contain section
        return NO;
    }
    
    NSDictionary<NSString *, NUACoalescedNotification *> *notificationGroups = self.notificationByIdentifier[request.sectionIdentifier];
    return [notificationGroups.allKeys containsObject:request.threadIdentifier];
}

- (BOOL)containsNotificationRequest:(NCNotificationRequest *)request {
    // Ensure on queue
    dispatch_assert_queue(_queue);

    if (![self containsThreadForRequest:request]) {
        // Thread doesnt even exist
        return NO;
    }

    // Access notifications asynchronously
    NUACoalescedNotification *notification = [self notificationForRequest:request];
    return [notification containsRequest:request];
}

- (NUACoalescedNotification *)notificationForRequest:(NCNotificationRequest *)request {
    // Ensure on queue
    dispatch_assert_queue(_queue);

    // Get from dictionary
    NSDictionary<NSString *, NUACoalescedNotification *> *notificationGroups = self.notificationByIdentifier[request.sectionIdentifier];
    return notificationGroups[request.threadIdentifier];
}

- (BOOL)insertNotificationRequest:(NCNotificationRequest *)request forCoalescedNotification:(NCCoalescedNotification *)coalescedNotification {
    // Ensure on queue
    dispatch_assert_queue(_queue);

    if ([[self.class _excludedSectionIdentifiers] containsObject:request.sectionIdentifier]) {
        return NO;
    }

    if (![self containsThreadForRequest:request]) {
        // Adding new entry
        return [self addNotificationRequest:request forCoalescedNotification:coalescedNotification];
    }

    // Update with new request
    NUACoalescedNotification *notification = [self notificationForRequest:request];
    [notification updateWithNewRequest:request];

    // Observer
    [self notifyObserversUsingBlock:^(id<NUANotificationsObserver> observer) {
        [observer notificationRepositoryUpdatedNotification:notification];
    }];

    // Figure out what to do with return value
    return YES;
}

- (BOOL)addNotificationRequest:(NCNotificationRequest *)request forCoalescedNotification:(NCCoalescedNotification *)coalescedNotification {
    // Ensure on queue
    dispatch_assert_queue(_queue);

    // Construct new notification
    NUACoalescedNotification *notification = nil;
    if (coalescedNotification) {
        notification = [NUACoalescedNotification coalescedNotificationFromNotification:coalescedNotification];
    } else {
        // Construct from request
        notification = [NUACoalescedNotification coalescedNotificationFromRequest:request];
    }

    // Add to dictionary
    NSMutableDictionary<NSString *, NUACoalescedNotification *> *notificationGroups = self.notificationByIdentifier[request.sectionIdentifier];
    if (!notificationGroups) {
        // Create if doesnt exist
        notificationGroups = [NSMutableDictionary dictionary];
    }

    // Update dictionary
    notificationGroups[request.threadIdentifier] = notification;
    self.notificationByIdentifier[request.sectionIdentifier] = notificationGroups;

    // Observer
    [self notifyObserversUsingBlock:^(id<NUANotificationsObserver> observer) {
        [observer notificationRepositoryAddedNotification:notification];
    }];

    return YES;
}

- (void)removeNotificationRequest:(NCNotificationRequest *)request forCoalescedNotification:(NCCoalescedNotification *)coalescedNotification {
    // Ensure on queue
    dispatch_assert_queue(_queue);

    if ([[self.class _excludedSectionIdentifiers] containsObject:request.sectionIdentifier]) {
        return;
    }

    if (![self containsNotificationRequest:request]) {
        // Cant remove something i dont have
        return;
    }

    // Remove request
    NUACoalescedNotification *notification = [self notificationForRequest:request];
    [notification removeRequest:request];

    // Determine action
    NUANotificationsObserverHandler handlerBlock = nil;
    if (notification.empty) {
        // Notification is empty, remove entirely
        NSMutableDictionary<NSString *, NUACoalescedNotification *> *notificationGroups = self.notificationByIdentifier[request.sectionIdentifier];
        [notificationGroups removeObjectForKey:request.threadIdentifier];
        self.notificationByIdentifier[request.sectionIdentifier] = notificationGroups;

        // Adjust handler
        handlerBlock = ^(id<NUANotificationsObserver> observer) {
            [observer notificationRepositoryRemovedNotification:notification];
        };
    } else {
        // Notification was simply modified
        handlerBlock = ^(id<NUANotificationsObserver> observer) {
            [observer notificationRepositoryUpdatedNotification:notification];
        };
    }

    // Observer
    [self notifyObserversUsingBlock:handlerBlock];
}

#pragma mark - Notification Clearing

- (NSMutableSet<NCNotificationRequest *> *)_allNotificationRequests {
    // Ensure on queue
    dispatch_assert_queue(_queue);

    // Query all requests
    NSMutableSet<NCNotificationRequest *> *allRequests = [NSMutableSet set];
    for (NSDictionary<NSString *, NUACoalescedNotification *> *notificationGroups in self.notificationByIdentifier.allValues) {
        NSArray<NUACoalescedNotification *> *notificationThreads = notificationGroups.allValues;
        for (NUACoalescedNotification *coalescedNotification in notificationThreads) {
            for (NUANotificationEntry *entry in coalescedNotification.entries) {
                [allRequests addObject:entry.request];
            }
        }
    }

    return allRequests;
}

- (void)purgeAllNotifications {
    // Ensure on queue
    dispatch_sync(_queue, ^{
        // Call to delegate
        NSMutableSet<NCNotificationRequest *> *allRequests = [self _allNotificationRequests];
        [self.delegate destination:self requestsClearingNotificationRequests:allRequests];

        // Clear table and dict
        for (NCNotificationRequest *request in allRequests) {
            [self removeNotificationRequest:request forCoalescedNotification:nil];
        }
    });
}

@end