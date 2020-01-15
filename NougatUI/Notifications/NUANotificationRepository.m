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
        // Create threads
        _observers = [NSHashTable weakObjectsHashTable];

        dispatch_queue_attr_t attributes = dispatch_queue_attr_make_with_autorelease_frequency(DISPATCH_QUEUE_SERIAL, DISPATCH_AUTORELEASE_FREQUENCY_NEVER);
        dispatch_queue_attr_t calloutAttributes = dispatch_queue_attr_make_with_qos_class(attributes, QOS_CLASS_USER_INTERACTIVE, 0);
        _callOutQueue = dispatch_queue_create("com.shade.nougat.notifications-provider.call-out", calloutAttributes);
    }

    return self;
}

#pragma mark - Properties

- (NSDictionary<NSString *, NSDictionary<NSString *, NUACoalescedNotification *> *> *)notifications {
    // Create synchronously
    if (_notifications) {
        return _notifications;
    }

    NSMutableDictionary<NSString *, NSDictionary<NSString *, NUACoalescedNotification *> *> *notifications = [NSMutableDictionary dictionary];
    NSMutableDictionary<NSString *, NCNotificationSection *> *notificationSections = [self _notificationStore].notificationSections;
    for (NSString *sectionIdentifier in notificationSections.allKeys) {
        if ([sectionIdentifier isEqualToString:@"com.apple.donotdisturb"] || [sectionIdentifier isEqualToString:@"com.apple.Passbook"] || [sectionIdentifier isEqualToString:@"com.apple.cmas"]) {
            // Exclude DND notification && wallet stuffs
            continue;
        }

        NCNotificationSection *section = notificationSections[sectionIdentifier];
        NSMutableDictionary<NSString *, NUACoalescedNotification *> *notificationGroups = [NSMutableDictionary dictionary];
        for (NSString *threadIdentifier in section.coalescedNotifications.allKeys) {
            // Apps can have different groups for notifications (eg: Followers and Likes groups)
            NCCoalescedNotification *coalescedNotification = section.coalescedNotifications[threadIdentifier];
            NUACoalescedNotification *notification = [NUACoalescedNotification coalescedNotificationFromNotification:coalescedNotification];
            notificationGroups[threadIdentifier] = notification;
        }

        notifications[sectionIdentifier] = [notificationGroups copy];
    }

    // Modify array synchronously
    @synchronized(_notifications) {
        _notifications = [notifications copy];
    }
        
    return _notifications;
}

- (NCNotificationStore *)_notificationStore {
    SBNCNotificationDispatcher *notificationDispatcher = [(SpringBoard *)[UIApplication sharedApplication] notificationDispatcher]; 
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
            handler(observer);
        }
    });
}

#pragma mark - Notification management

- (BOOL)containsThreadForRequest:(NCNotificationRequest *)request {
    // Access notifications synchronously
    __block NSDictionary<NSString *, NUACoalescedNotification *> *notificationGroups;
    @synchronized(_notifications) {
        // Already inside queue
        BOOL containsSection = [_notifications.allKeys containsObject:request.sectionIdentifier];
        if (containsSection) {
            // Check if contains thread
            notificationGroups = _notifications[request.sectionIdentifier];
        }
    }
    
    return (notificationGroups != nil) && [notificationGroups.allKeys containsObject:request.threadIdentifier];
}

- (BOOL)containsNotificationRequest:(NCNotificationRequest *)request {
    if (![self containsThreadForRequest:request]) {
        // Thread doesnt even exist
        return NO;
    }

    // Access notifications synchronously
    __block NUACoalescedNotification *notification;
    @synchronized(_notifications) {
        // Get notif and check
        NSDictionary<NSString *, NUACoalescedNotification *> *notificationGroups = _notifications[request.sectionIdentifier];
        notification = notificationGroups[request.threadIdentifier];
    }

    return [notification containsRequest:request];
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

    // Access notifications synchronously
    __block NUACoalescedNotification *notification;
    @synchronized(_notifications) {
        // Get notification
        NSDictionary<NSString *, NUACoalescedNotification *> *notificationGroups = _notifications[request.sectionIdentifier];
        notification = notificationGroups[request.threadIdentifier];
    }

    // Update with new request
    [notification updateWithNewRequest:request];

    // Observer
    NUANotificationsObserverHandler handlerBlock = ^(id<NUANotificationsObserver> observer) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [observer notificationRepositoryUpdatedNotification:notification updateIndex:YES];
        });
    };

    [self notifyObserversUsingBlock:handlerBlock];

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

    // Modify dictionary synchronously
    @synchronized(_notifications) {
        // Add to dictionary
        NSDictionary<NSString *, NUACoalescedNotification *> *notificationGroups = _notifications[request.sectionIdentifier];
        if (!notificationGroups) {
            // Create if doesnt exist
            notificationGroups = [NSDictionary dictionary];
        }

        // Update dictionary
        NSMutableDictionary<NSString *, NUACoalescedNotification *> *mutableNotificationGroups = [notificationGroups mutableCopy];
        mutableNotificationGroups[request.threadIdentifier] = notification;

        NSMutableDictionary<NSString *, NSDictionary<NSString *, NUACoalescedNotification *> *> *notifications = [_notifications mutableCopy];
        notifications[request.sectionIdentifier] = [mutableNotificationGroups copy];
        _notifications = [notifications copy];
    }

    // Observer
    NUANotificationsObserverHandler handlerBlock = ^(id<NUANotificationsObserver> observer) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [observer notificationRepositoryAddedNotification:notification];
        });
    };

    [self notifyObserversUsingBlock:handlerBlock];

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

    // Access notifications synchronously
    __block NUACoalescedNotification *notification;
    @synchronized(_notifications) {
        NSDictionary<NSString *, NUACoalescedNotification *> *notificationGroups = _notifications[request.sectionIdentifier];
        notification = notificationGroups[request.threadIdentifier];
    }

    // Remove
    [notification removeRequest:request];

    // Determine action
    NUANotificationsObserverHandler handlerBlock = nil;
    if (notification.empty) {
        // Access notifications synchronously
        @synchronized(_notifications) {
            NSDictionary<NSString *, NUACoalescedNotification *> *notificationGroups = _notifications[request.sectionIdentifier];

            // Notification is empty, remove entirely
            NSMutableDictionary<NSString *, NUACoalescedNotification *> *mutableNotificationGroups = [notificationGroups mutableCopy];
            [mutableNotificationGroups removeObjectForKey:request.threadIdentifier];

            // Update main dict
            NSMutableDictionary<NSString *, NSDictionary<NSString *, NUACoalescedNotification *> *> *notifications = [_notifications mutableCopy];
            notifications[request.sectionIdentifier] = [mutableNotificationGroups copy];
            _notifications = [notifications copy];
        }

        // Adjust handler
        handlerBlock = ^(id<NUANotificationsObserver> observer) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [observer notificationRepositoryRemovedNotification:notification];
            });
        };
    } else {
        // Notification was simply modified
        handlerBlock = ^(id<NUANotificationsObserver> observer) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [observer notificationRepositoryUpdatedNotification:notification updateIndex:NO];
            });
        };
    }

    // Observer
    [self notifyObserversUsingBlock:handlerBlock];
}

- (void)purgeAllNotifications {
    // Queue synchronously
    @synchronized(_notifications) {
        // Simply reset ivar and regen
        _notifications = nil;

        // Call to regen
        [self notifications];
    }
}

@end