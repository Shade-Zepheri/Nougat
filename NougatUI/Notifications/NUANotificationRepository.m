#import "NUANotificationRepository.h"
#import <SpringBoard/SpringBoard-Umbrella.h>

@implementation NUANotificationRepository

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
        _notifications = [NSMutableDictionary dictionary];
        _shouldRegenerate = YES;

        // Create threads
        dispatch_queue_attr_t attributes = dispatch_queue_attr_make_with_autorelease_frequency(DISPATCH_QUEUE_SERIAL, DISPATCH_AUTORELEASE_FREQUENCY_NEVER);
        dispatch_queue_attr_t calloutAttributes = dispatch_queue_attr_make_with_qos_class(attributes, QOS_CLASS_USER_INTERACTIVE, 0);
        _callOutQueue = dispatch_queue_create("com.shade.nougat.notifications-provider.call-out", calloutAttributes);

        // Load notifications
        [self _populateNotificationsIfNecessary];
    }

    return self;
}

#pragma mark - Populating Notifications

- (void)_populateNotificationsIfNecessary {
    if (!_shouldRegenerate) {
        return;
    }

    // Reset flag
    _shouldRegenerate = NO;

    // Create dictionary
    NSMutableDictionary<NSString *, NSDictionary<NSString *, NUACoalescedNotification *> *> *notifications = [NSMutableDictionary dictionary];
    NSMutableDictionary<NSString *, NCNotificationSection *> *notificationSections = [self _notificationStore].notificationSections;
    for (NSString *sectionIdentifier in notificationSections.allKeys) {
        if ([sectionIdentifier isEqualToString:@"com.apple.donotdisturb"] || [sectionIdentifier isEqualToString:@"com.apple.Passbook"] || [sectionIdentifier isEqualToString:@"com.apple.cmas"]) {
            // Exclude DND notification && wallet stuffs
            continue;
        }

        NCNotificationSection *section = notificationSections[sectionIdentifier];
        NSMutableDictionary<NSString *, NUACoalescedNotification *> *notificationGroups = [NSMutableDictionary dictionary];
        if ([section respondsToSelector:@selector(coalescedNotifications)]) {
            // iOS 10-12
            for (NSString *threadIdentifier in section.coalescedNotifications.allKeys) {
                // Apps can have different groups for notifications (eg: Followers and Likes groups)
                NCCoalescedNotification *coalescedNotification = section.coalescedNotifications[threadIdentifier];
                NUACoalescedNotification *notification = [NUACoalescedNotification coalescedNotificationFromNotification:coalescedNotification];
                notificationGroups[threadIdentifier] = notification;
            }
        } else {
            // iOS 13+
            for (NCNotificationRequest *request in section.requests.allValues) {
                // Section contains all requests, sort based on threadID
                NSString *threadIdentifier = request.threadIdentifier;
                if (!notificationGroups[threadIdentifier]) {
                    // Create new notification entry
                    NUACoalescedNotification *notification = [NUACoalescedNotification coalescedNotificationFromRequest:request];
                    notificationGroups[threadIdentifier] = notification;
                } else {
                    NUACoalescedNotification *notification = notificationGroups[threadIdentifier];
                    [notification updateWithNewRequest:request];
                    notificationGroups[threadIdentifier] = notification;
                }
            }
        }

        notifications[sectionIdentifier] = [notificationGroups copy];
    }

    // Modify array synchronously
    _notifications = [notifications copy];
}

- (NCNotificationStore *)_notificationStore {
    SBNCNotificationDispatcher *notificationDispatcher = ((SpringBoard *)UIApplication.sharedApplication).notificationDispatcher; 
    SBDashBoardNotificationDispatcher *destination = notificationDispatcher.dashBoardDestination;
    NCNotificationDispatcher *dispatcher = destination.delegate;
    return dispatcher.notificationStore;
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
    // Dispatch on calloutQueue
    dispatch_async(_callOutQueue, ^{
        NSArray *observers = [_observers.allObjects copy];

        for (id<NUANotificationsObserver> observer in observers) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(observer);
            });
        }
    });
}

#pragma mark - Notification management

- (BOOL)containsThreadForRequest:(NCNotificationRequest *)request {
    // Access notifications asynchronously
    NSDictionary<NSString *, NUACoalescedNotification *> *notificationGroups;
    BOOL containsSection = [self.notifications.allKeys containsObject:request.sectionIdentifier];
    if (containsSection) {
        // Check if contains thread
        notificationGroups = self.notifications[request.sectionIdentifier];
    }
    
    return (notificationGroups != nil) && [notificationGroups.allKeys containsObject:request.threadIdentifier];
}

- (BOOL)containsNotificationRequest:(NCNotificationRequest *)request {
    if (![self containsThreadForRequest:request]) {
        // Thread doesnt even exist
        return NO;
    }

    // Access notifications asynchronously
    NUACoalescedNotification *notification = [self notificationForRequest:request];
    return [notification containsRequest:request];
}

- (NUACoalescedNotification *)notificationForRequest:(NCNotificationRequest *)request {
    // Get from dictionary
    NSDictionary<NSString *, NUACoalescedNotification *> *notificationGroups = self.notifications[request.sectionIdentifier];
    return notificationGroups[request.threadIdentifier];
}

- (BOOL)insertNotificationRequest:(NCNotificationRequest *)request forCoalescedNotification:(NCCoalescedNotification *)coalescedNotification {
    if ([request.sectionIdentifier isEqualToString:@"com.apple.donotdisturb"] || [request.sectionIdentifier isEqualToString:@"com.apple.Passbook"] || [request.sectionIdentifier isEqualToString:@"com.apple.cmas"]) {
        // Exclude DND notification and wallet
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
        [observer notificationRepositoryUpdatedNotification:notification removedRequest:NO];
    }];

    // Figure out what to do with return value
    return YES;
}

- (BOOL)addNotificationRequest:(NCNotificationRequest *)request forCoalescedNotification:(NCCoalescedNotification *)coalescedNotification {
    // Construct new notification
    NUACoalescedNotification *notification = nil;
    if (coalescedNotification) {
        notification = [NUACoalescedNotification coalescedNotificationFromNotification:coalescedNotification];
    } else {
        // Construct from request
        notification = [NUACoalescedNotification coalescedNotificationFromRequest:request];
    }

    // Add to dictionary
    NSDictionary<NSString *, NUACoalescedNotification *> *notificationGroups = self.notifications[request.sectionIdentifier];
    if (!notificationGroups) {
        // Create if doesnt exist
        notificationGroups = [NSDictionary dictionary];
    }

    // Update dictionary
    NSMutableDictionary<NSString *, NUACoalescedNotification *> *mutableNotificationGroups = [notificationGroups mutableCopy];
    mutableNotificationGroups[request.threadIdentifier] = notification;

    NSMutableDictionary<NSString *, NSDictionary<NSString *, NUACoalescedNotification *> *> *notifications = [self.notifications mutableCopy];
    notifications[request.sectionIdentifier] = [mutableNotificationGroups copy];
    _notifications = [notifications copy];

    // Observer
    [self notifyObserversUsingBlock:^(id<NUANotificationsObserver> observer) {
        [observer notificationRepositoryAddedNotification:notification];
    }];

    return YES;
}

- (void)removeNotificationRequest:(NCNotificationRequest *)request forCoalescedNotification:(NCCoalescedNotification *)coalescedNotification {
    if ([request.sectionIdentifier isEqualToString:@"com.apple.donotdisturb"] || [request.sectionIdentifier isEqualToString:@"com.apple.Passbook"] || [request.sectionIdentifier isEqualToString:@"com.apple.cmas"]) {
        // Exclude DND notification and wallet
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
        // Access notifications serially
        NSDictionary<NSString *, NUACoalescedNotification *> *notificationGroups = self.notifications[request.sectionIdentifier];

        // Notification is empty, remove entirely
        NSMutableDictionary<NSString *, NUACoalescedNotification *> *mutableNotificationGroups = [notificationGroups mutableCopy];
        [mutableNotificationGroups removeObjectForKey:request.threadIdentifier];

        // Update main dict
        NSMutableDictionary<NSString *, NSDictionary<NSString *, NUACoalescedNotification *> *> *notifications = [self.notifications mutableCopy];
        notifications[request.sectionIdentifier] = [mutableNotificationGroups copy];
        _notifications = [notifications copy];

        // Adjust handler
        handlerBlock = ^(id<NUANotificationsObserver> observer) {
            [observer notificationRepositoryRemovedNotification:notification];
        };
    } else {
        // Notification was simply modified
        handlerBlock = ^(id<NUANotificationsObserver> observer) {
            [observer notificationRepositoryUpdatedNotification:notification removedRequest:YES];
        };
    }

    // Observer
    [self notifyObserversUsingBlock:handlerBlock];
}

- (void)purgeAllNotifications {
    // Set needs regeneration
    _shouldRegenerate = YES;
    [self _populateNotificationsIfNecessary];
}

@end