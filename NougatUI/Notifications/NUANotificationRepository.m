#import "NUANotificationRepository.h"
#import <SpringBoard/SpringBoard-Umbrella.h>
#import <UserNotificationsKit/UserNotificationsKit.h>

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
// 5       UserNotificationsServer         0x1d3cc58cc 0x1d3c73000 + 0x528cc       // -[UNSNotificationRepository notificationRecordsForBundleIdentifier:] + 0x9c
// 6       UserNotificationsServer         0x1d3caab2c 0x1d3c73000 + 0x37b2c       // -[UNSDefaultDataProvider notificationRecords] + 0x44
// 7       UserNotificationsServer         0x1d3caa77c 0x1d3c73000 + 0x3777c       // -[UNSDefaultDataProvider _allBulletinsWithMaxCount:sinceDate:] + 0x84
// 8       UserNotificationsServer         0x1d3caac08 0x1d3c73000 + 0x37c08       // -[UNSDefaultDataProvider bulletinsWithRequestParameters:lastCleared:] + 0xb8
/*

dispatcher = SpringBoard.notificationDispatcher
dispatcher = SBNCNotificationDispatcher.dashBoardDestination
dispatcher = SBDashBoardNotificationDispatcher.delegate
store = NCNotificationDispatcher.notificationStore
notifs = NCNotificationStore.notificationSections
section<NCNotificationSection> = obj in notifs
notif<NCMutableCoalescedNotification> = obj in section.coalescedNotifications
request<NCNotificationRequest> = obj in notif.notificationRequests
content<NCNotificationContent> = request.content
*/
    // Only generate once and have it be updated
    if (_notifications) {
        return _notifications;
    }

    NSMutableDictionary<NSString *, NSArray<NUACoalescedNotification *> *> *notifications = [NSMutableDictionary dictionary];
    NSMutableDictionary<NSString *, NCNotificationSection *> *notificationSections = [self _notificationStore].notificationSections;
    NSArray<NSString *> *sectionIdentifiers = notificationSections.allKeys;
    for (NSString *sectionIdentifier in sectionIdentifiers) {
        if ([sectionIdentifier isEqualToString:@"com.apple.donotdisturb"]) {
            // Exclude DND notification
            continue;
        }

        NCNotificationSection *section = notificationSections[sectionIdentifier];
        NSMutableArray<NUACoalescedNotification *> *notificationGroups = [NSMutableArray array];
        for (NCCoalescedNotification *coalescedNotification in section.coalescedNotifications.allValues) {
            // Apps can have different groups for notifications (eg: Followers and Likes groups)
            NUACoalescedNotification *notification = [self _coalescedNotificationFromNotification:coalescedNotification];
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

#pragma mark - Nougat equivalents

- (NUACoalescedNotification *)_coalescedNotificationFromNotification:(NCCoalescedNotification *)coalescedNotification {
    // Construct entires
    NSMutableArray<NUANotificationEntry *> *entries = [NSMutableArray array];
    NSArray<NCNotificationRequest *> *notificationRequests = coalescedNotification.notificationRequests;
    for (NCNotificationRequest *request in notificationRequests) {
        NUANotificationEntry *entry = [self _entryFromRequest:request];
        [entries addObject:entry];
    }

    // Sort entires
    [entries sortUsingComparator:^(NUANotificationEntry *entry1, NUANotificationEntry *entry2) {
        return [entry2.timestamp compare:entry1.timestamp];
	}];

    // Construct NUA equivalent
    NCNotificationContent *content = coalescedNotification.content;
    NUACoalescedNotification *notification = [NUACoalescedNotification coalescedNotificationWithSectionID:coalescedNotification.sectionIdentifier threadID:coalescedNotification.threadIdentifier title:content.title message:content.message entires:entries];
    return notification;
}

- (NUANotificationEntry *)_entryFromRequest:(NCNotificationRequest *)request {
    NCNotificationContent *content = request.content;
    return[NUANotificationEntry notificationEntryWithTitle:content.title message:content.message timestamp:request.timestamp];
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

@end