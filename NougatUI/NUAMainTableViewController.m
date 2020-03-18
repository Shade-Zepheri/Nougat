#import "NUAMainTableViewController.h"
#import "NUAMediaTableViewCell.h"
#import <MediaRemote/MediaRemote.h>
#import <Macros.h>

@implementation NUAMainTableViewController

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        // Create defaults
        _expandedCells = [NSMutableArray array];

        // Create tableview controller
        _tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
        [self addChildViewController:self.tableViewController];

        // Create now playing controller
        _nowPlayingController = [[NSClassFromString(@"MPUNowPlayingController") alloc] init];

        // Notifications
        _notificationRepository = [NUANotificationRepository defaultRepository];
        [self.notificationRepository addObserver:self];
    }

    return self;
}

- (void)_loadNotificationsIfNecessary {
    if (_notifications) {
        // Generate only once
        return;
    }

    // Fuck it just add all of them for now
    NSDictionary<NSString *, NSDictionary<NSString *, NUACoalescedNotification *> *> *allNotifications = self.notificationRepository.notifications;
    NSMutableArray<NUACoalescedNotification *> *notifications = [NSMutableArray array];
    for (NSDictionary<NSString *, NUACoalescedNotification *> *notificationGroups in allNotifications.allValues) {
        // Add all entries from each array
        NSArray<NUACoalescedNotification *> *notificationThreads = notificationGroups.allValues;
        [notifications addObjectsFromArray:notificationThreads];
    }

    // Sort via date
    [notifications sortUsingComparator:^(NUACoalescedNotification *notification1, NUACoalescedNotification *notification2) {
        return [notification2.timestamp compare:notification1.timestamp];
    }];

    _notifications = [notifications copy];
}

#pragma mark - Properties

- (CGFloat)contentHeight {
    return self.tableViewController.tableView.contentSize.height;
}

- (void)setPresentedHeight:(CGFloat)height {
    _presentedHeight = height;
    if (height < 150.0) {
        // Only start to expand once panel in view
        return;
    }

    _heightConstraint.constant = height - 150.0;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"revealPercentage"]) {
        // Adjust table frame
        CGFloat revealPercentage = [change[NSKeyValueChangeNewKey] floatValue]; 
        CGFloat expandedHeight = 350 * revealPercentage;

        CGFloat currentHeight = expandedHeight + self.presentedHeight;
        CGFloat heightDifference = kScreenHeight - currentHeight;
        if (heightDifference >= 200) {
            // Have a tolerance to do nothing
            return;
        }

        CGFloat extraHeight = 100 - heightDifference;
        self.presentedHeight -= extraHeight;
    } else if ([keyPath isEqualToString:@"presentedHeight"]) {
        // Update height
        CGFloat presentedHeight = [change[NSKeyValueChangeNewKey] floatValue]; 
        self.presentedHeight = presentedHeight;
    }
}

#pragma mark - Observer

- (void)notificationRepositoryAddedNotification:(NUACoalescedNotification *)newNotification {
    if (!_notifications) {
        // Notification shade hasnt been loaded
        return;
    }

    // Add new entry
    NSMutableArray<NUACoalescedNotification *> *notifications = [_notifications mutableCopy];
    NSUInteger index = [self _mediaCellPresent] ? 1 : 0;
    [notifications insertObject:newNotification atIndex:index];

    // Update ivar
    _notifications = [notifications copy];

    // Update table
    [self.tableViewController.tableView beginUpdates];

    [self.tableViewController.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];

    [self.tableViewController.tableView endUpdates];
}

- (void)notificationRepositoryUpdatedNotification:(NUACoalescedNotification *)updatedNotification updateIndex:(BOOL)updateIndex {
    if (!_notifications) {
        // Notification shade hasnt been loaded
        return;
    }

    // Get old notification 
    NSMutableArray<NUACoalescedNotification *> *notifications = [_notifications mutableCopy];
    NUACoalescedNotification *oldNotification = [self coalescedNotificationForSectionID:updatedNotification.sectionID threadID:updatedNotification.threadID];

    // Remove old and add new      
    NSUInteger oldIndex = [notifications indexOfObject:oldNotification];
    NSUInteger newIndex = updateIndex ? ([self _mediaCellPresent] ? 1 : 0) : oldIndex;
    [notifications removeObject:oldNotification];
    [notifications insertObject:updatedNotification atIndex:newIndex];

    // Update ivar
    _notifications = [notifications copy];

    // Update table
    [self.tableViewController.tableView beginUpdates];

    if (newIndex == oldIndex) {
        // Simply just reload the cell, no need to insert and delete
        [self.tableViewController.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:newIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [self.tableViewController.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:oldIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableViewController.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:newIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }

    [self.tableViewController.tableView endUpdates];
}

- (void)notificationRepositoryRemovedNotification:(NUACoalescedNotification *)removedNotification {
    if (!_notifications) {
        // Notification shade hasnt been loaded
        return;
    }

    // Get old notification 
    NSMutableArray<NUACoalescedNotification *> *notifications = [_notifications mutableCopy];
    NUACoalescedNotification *oldNotification = [self coalescedNotificationForSectionID:removedNotification.sectionID threadID:removedNotification.threadID];

    // Remove old
    NSUInteger oldIndex = [notifications indexOfObject:oldNotification];
    [notifications removeObject:oldNotification];

    // Update ivar
    _notifications = [notifications copy];

    // Update table
    [self.tableViewController.tableView beginUpdates];

    [self.tableViewController.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:oldIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];

    [self.tableViewController.tableView endUpdates];
}

- (NUACoalescedNotification *)coalescedNotificationForSectionID:(NSString *)sectionID threadID:(NSString *)threadID {
    for (NUACoalescedNotification *notification in _notifications) {
        if (![notification.sectionID isEqualToString:sectionID] || ![notification.threadID isEqualToString:threadID]) {
            // Make sure its the same notification
            continue;
        }

        return notification;
    }

    return nil;
}

- (void)executeNotificationAction:(NSString *)type forCellAtIndexPath:(NSIndexPath *)indexPath {
    // Get associated entry
    NUACoalescedNotification *notification = _notifications[indexPath.row];
    NUANotificationEntry *entry = notification.entries[0];

    // Get action
    NCNotificationAction *action = nil;
    if ([type isEqualToString:@"default"]) {
        action = entry.request.defaultAction;
    } else if ([type isEqualToString:@"clear"]) {
        action = entry.request.clearAction;
    }

    if (!action) {
        // No action
        return;
    }

    // Post to launch
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NUANotificationLaunchNotification" object:nil userInfo:@{@"type": type, @"action": action, @"request": entry.request}];

    if ([type isEqualToString:@"default"]) {
        // Dismiss
        [self.delegate tableViewControllerWantsDismissal:self];
    }
}

#pragma mark - UIViewController

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    _heightConstraint = [view.heightAnchor constraintEqualToConstant:20.0];
    _heightConstraint.active = YES;
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Configure tableView
    self.tableViewController.tableView.dataSource = self;
    self.tableViewController.tableView.delegate = self;
    self.tableViewController.tableView.estimatedRowHeight = 100.0;
    self.tableViewController.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableViewController.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableViewController.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableViewController.tableView];

    self.tableViewController.tableView.layoutMargins = UIEdgeInsetsZero;
    self.tableViewController.tableView.separatorInset = UIEdgeInsetsZero;

    // // constraint up
    [self.tableViewController.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.tableViewController.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.tableViewController.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.tableViewController.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;

    // Register custom classes
    [self.tableViewController.tableView registerClass:[NUANotificationTableViewCell class] forCellReuseIdentifier:@"NotificationCell"];
    [self.tableViewController.tableView registerClass:[NUAMediaTableViewCell class] forCellReuseIdentifier:@"MediaCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // GCD this mug
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
        // Populate
        [self _loadNotificationsIfNecessary];
    });

    // Notifications
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(_reloadForExpansion:) name:@"NUATableCellWantsReloadNotification" object:nil];
    [center addObserver:self selector:@selector(_updateMedia) name:(__bridge_transfer NSString *)kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification object:nil];

    // Update media if needed
    [self _updateMedia];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // Stop listening for Notifs
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:@"NUATableCellWantsReloadNotification" object:nil];
    [center removeObserver:self name:(__bridge_transfer NSString *)kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification object:nil];

    // Remove media cell if needed
    [self removeMediaCellIfNecessary];
}

#pragma mark - Notifications

- (void)_reloadForExpansion:(NSNotification *)notification {
    // Simple reload
    [self.tableViewController.tableView beginUpdates];
    [self.tableViewController.tableView endUpdates];
}

- (void)_updateMedia {
    // Media stuffs
    [self insertMediaCellIfNeccessary];
}

#pragma mark - Media

- (BOOL)_mediaCellPresent {
    if (!_notifications || _notifications.count == 0) {
        // Cant check something that doesnt exist
        return NO;
    }

    // Since is always gonna be top notif, only check it
    NUACoalescedNotification *topNotification = _notifications[0];
    return topNotification.type == NUANotificationTypeMedia;
}

- (void)insertMediaCellIfNeccessary {
    if ([self _mediaCellPresent] || !self.nowPlayingController.isPlaying || !_notifications) {
        // cant add if already exists, or not playing, or if nothing to add to
        return;
    }

    // Add dummie to backng array
    NSMutableArray<NUACoalescedNotification *> *mutableNotifications = [_notifications mutableCopy];
    NUACoalescedNotification *mediaNotification = [NUACoalescedNotification mediaNotification];
    [mutableNotifications insertObject:mediaNotification atIndex:0];
    _notifications = [mutableNotifications copy];

    // Reload row
    [self.tableViewController.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)removeMediaCellIfNecessary {
    if (![self _mediaCellPresent] || self.nowPlayingController.isPlaying) {
        // Cant remove something i dont have or cant remove something i need
        return;
    }

    // Remove media cell
    NSMutableArray<NUACoalescedNotification *> *mutableNotifications = [_notifications mutableCopy];
    [mutableNotifications removeObjectAtIndex:0];
    _notifications = [mutableNotifications copy];

    // Reload row
    [self.tableViewController.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![cell isKindOfClass:[NUAMediaTableViewCell class]]) {
        // Not media cell
        return;
    }

    // Register media cell notifications
    NUAMediaTableViewCell *mediaCell = (NUAMediaTableViewCell *)cell;
    [mediaCell registerForMediaNotifications];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![cell isKindOfClass:[NUAMediaTableViewCell class]]) {
        // Not media cell
        return;
    }

    // Unregister media cell notifications
    NUAMediaTableViewCell *mediaCell = (NUAMediaTableViewCell *)cell;
    [mediaCell unregisterForMediaNotifications];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0 && [self _mediaCellPresent]) {
        // Is media cell
        return;
    }

    // Launch notif
    [self executeNotificationAction:@"default" forCellAtIndexPath:indexPath];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _notifications.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NUACoalescedNotification *notification = _notifications[indexPath.row];
    if (notification.type == NUANotificationTypeMedia) {
        NUAMediaTableViewCell *mediaCell = [tableView dequeueReusableCellWithIdentifier:@"MediaCell" forIndexPath:indexPath];

        // Provide basic information
        mediaCell.delegate = self;
        mediaCell.expanded = [_expandedCells containsObject:indexPath];
        mediaCell.layoutMargins = UIEdgeInsetsZero;

        return mediaCell;
    }

    NUANotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCell" forIndexPath:indexPath];
    cell.actionsDelegate = self;
    cell.delegate = self;
    cell.expanded = [_expandedCells containsObject:indexPath];
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.notification = notification;

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - Cells delegate

- (void)tableViewCell:(NUATableViewCell *)cell wantsExpansion:(BOOL)expand; {
    // Add indexpath to expanded bois
    NSIndexPath *indexPath = [self.tableViewController.tableView indexPathForCell:cell];
    if (expand) {
        [_expandedCells addObject:indexPath];
    } else {
        [_expandedCells removeObject:indexPath];
    }

    // Reload
    [self.tableViewController.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)notificationTableViewCellRequestsExecuteDefaultAction:(NUANotificationTableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableViewController.tableView indexPathForCell:cell];

    // Launch notif
    [self executeNotificationAction:@"default" forCellAtIndexPath:indexPath];
}

- (void)notificationTableViewCellRequestsExecuteAlternateAction:(NUANotificationTableViewCell *)cell {
    // Figure this out
    NSIndexPath *indexPath = [self.tableViewController.tableView indexPathForCell:cell];

    // Launch notif
    [self executeNotificationAction:@"clear" forCellAtIndexPath:indexPath];
}

@end