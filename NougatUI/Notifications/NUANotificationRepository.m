#import "NUANotificationRepository.h"
#import "NSArray+Map.h"
#import <SpringBoard/SpringBoard-Umbrella.h>
#import <HBLog.h>

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

        dispatch_queue_attr_t attributes = dispatch_queue_attr_make_with_autorelease_frequency(nil, DISPATCH_AUTORELEASE_FREQUENCY_NEVER);
		dispatch_queue_attr_t mainAttributes = dispatch_queue_attr_make_with_qos_class(attributes, QOS_CLASS_USER_INITIATED, 0);
		_queue = dispatch_queue_create("com.shade.nougat.notifications-provider", mainAttributes);

        dispatch_queue_attr_t calloutAttributes = dispatch_queue_attr_make_with_qos_class(attributes, QOS_CLASS_USER_INTERACTIVE, 0);
		_callOutQueue = dispatch_queue_create("com.shade.nougat.notifications-provider.call-out", calloutAttributes);
    }

    return self;
}

#pragma mark - Properties

- (NSDictionary<NSString *, NSArray<NUACoalescedNotification *> *> *)notifications {
    if (_notifications) {
        return _notifications;
    }

    NSMutableDictionary<NSString *, NSArray<NUACoalescedNotification *> *> *notifications = [NSMutableDictionary dictionary];
    NSMutableDictionary<NSString *, NCNotificationSection *> *notificationSections = [self _notificationStore].notificationSections;
    NSArray<NSString *> *sectionIdentifiers = notificationSections.allKeys;
    for (NSString *sectionIdentifier in sectionIdentifiers) {
        if ([sectionIdentifier isEqualToString:@"com.apple.donotdisturb"] || [sectionIdentifier isEqualToString:@"com.apple.Passbook"]) {
            // Exclude DND notification && wallet stuffs
            continue;
        }

        NCNotificationSection *section = notificationSections[sectionIdentifier];
        NSMutableArray<NUACoalescedNotification *> *notificationGroups = [NSMutableArray array];
        for (NCCoalescedNotification *coalescedNotification in section.coalescedNotifications.allValues) {
            // Apps can have different groups for notifications (eg: Followers and Likes groups)
            NUACoalescedNotification *notification = [NUACoalescedNotification coalescedNotificationFromNotification:coalescedNotification];
            [notificationGroups addObject:notification];
        }

        notifications[sectionIdentifier] = [notificationGroups copy];
    }

    _notifications = [notifications copy];
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
    dispatch_sync(_queue, ^{
        if ([_observers containsObject:observer]) {
            return;
        }

        [_observers addObject:observer];
    });
}

- (void)removeObserver:(id<NUANotificationsObserver>)observer {
    dispatch_sync(_queue, ^{
        if (![_observers containsObject:observer]) {
            return;
        }

        [_observers removeObject:observer];
    });
}

- (void)notifyObserversUsingBlock:(NUANotificationsObserverHandler)handler {
    // Dispatch on calloutQueue
    dispatch_async(_callOutQueue, ^{
        __block NSArray *observers;

        dispatch_sync(_queue, ^{
            observers = [_observers.allObjects copy];
        });

        for (id<NUANotificationsObserver> observer in observers) {
            dispatch_async(_queue, ^{
                handler(observer);
            });
        }
    });
}

#pragma mark - Notification management

- (BOOL)containsNotificationForRequest:(NCNotificationRequest *)request {
    BOOL containsSection = [_notifications.allKeys containsObject:request.sectionIdentifier];
    if (!containsSection) {
        return NO;
    }

    // Fun little trick
    NSArray<NUACoalescedNotification *> *notificationGroups = _notifications[request.sectionIdentifier];
    NSArray<NSString *> *threadIdentifiers = [notificationGroups map:^id(id obj) {
        return ((NUACoalescedNotification *)obj).threadID;
    }];

    return [threadIdentifiers containsObject:request.threadIdentifier];
}

- (BOOL)insertNotificationRequest:(NCNotificationRequest *)request forCoalescedNotification:(NCCoalescedNotification *)coalescedNotification {
    if ([request.sectionIdentifier isEqualToString:@"com.apple.donotdisturb"] || [request.sectionIdentifier isEqualToString:@"com.apple.Passbook"]) {
        // Exclude DND notification
        return NO;
    }

    if (![self containsNotificationForRequest:request]) {
        // Adding new entry
        return [self addNotificationRequest:request forCoalescedNotification:coalescedNotification];
    }

    // Update notification
    NSArray<NUACoalescedNotification *> *notificationGroups = _notifications[request.sectionIdentifier];
    for (NUACoalescedNotification *notification in notificationGroups) {
        if (![notification.threadID isEqualToString:request.threadIdentifier]) {
            continue;
        }

        NUANotificationEntry *entry = [NUANotificationEntry notificationEntryFromRequest:request];
        [notification updateWithNewEntry:entry];

        // Observer
        NUANotificationsObserverHandler handlerBlock = ^(id<NUANotificationsObserver> observer) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [observer notificationRepositoryUpdatedNotification:notification];
            });
        };

        [self notifyObserversUsingBlock:handlerBlock];
    }

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
    NSArray<NUACoalescedNotification *> *notificationGroups = _notifications[request.sectionIdentifier];
    if (!notificationGroups) {
        // Create if doesnt exist
        notificationGroups = [NSArray array];
    }

    NSMutableArray<NUACoalescedNotification *> *mutableArray = [notificationGroups mutableCopy];

    // Update
    [mutableArray addObject:notification];
    NSMutableDictionary<NSString *, NSArray<NUACoalescedNotification *> *> *notifications = [_notifications mutableCopy];
    notifications[request.sectionIdentifier] = [mutableArray copy];
    _notifications = [notifications copy];

    // Observer
    NUANotificationsObserverHandler handlerBlock = ^(id<NUANotificationsObserver> observer) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [observer notificationRepositoryAddedNotification:notification];
        });
    };

    [self notifyObserversUsingBlock:handlerBlock];

    return YES;
}

@end