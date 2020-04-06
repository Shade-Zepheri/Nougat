#import "NUAMainTableViewController.h"
#import "NUAMediaTableViewCell.h"
#import <MediaRemote/MediaRemote.h>
#import <SpringBoard/SpringBoard.h>
#import <Macros.h>

@interface NUAMainTableViewController () {
    NSMutableArray<NUACoalescedNotification *> *_expandedNotifications;
    NSLayoutConstraint *_heightConstraint;
    NUACoalescedNotification *_mediaNotification;
}

@end

@implementation NUAMainTableViewController

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        // Create defaults
        _expandedNotifications = [NSMutableArray array];
        _mediaNotification = [NUACoalescedNotification mediaNotification];

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
    if (self.notifications) {
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
        // Since cant really return here, ensure proper height set
        height = 150.0;
    }

    _heightConstraint.constant = height - 150.0;
}

- (void)setRevealPercentage:(CGFloat)revealPercentage {
    _revealPercentage = revealPercentage;

    // Adjust whether table should start cutting off
    CGFloat fullPanelHeight = [self.delegate tableViewControllerRequestsPanelContentHeight:self];
    CGFloat safeAreaHeight = kScreenHeight - 100.0;
    if ((self.contentHeight + fullPanelHeight) <= safeAreaHeight) {
        // No need to ever cutoff
        return;
    }

    // Calculate cutoff
    CGFloat originalPresentedHeight = MIN(safeAreaHeight, self.contentHeight + 150.0);
    CGFloat addedHeight = ((fullPanelHeight - 150.0) * revealPercentage);
    CGFloat totalHeight = originalPresentedHeight + addedHeight;
    CGFloat heightToRemove = totalHeight - safeAreaHeight;
    CGFloat newPresentedHeight = originalPresentedHeight - heightToRemove;
    if (newPresentedHeight > originalPresentedHeight) {
        newPresentedHeight = originalPresentedHeight;
    }

    self.presentedHeight = newPresentedHeight;
}

#pragma mark - Observer

- (void)notificationRepositoryAddedNotification:(NUACoalescedNotification *)newNotification {
    if (!self.notifications) {
        // Notification shade hasnt been loaded
        return;
    }

    // Add new entry
    NSMutableArray<NUACoalescedNotification *> *notifications = [self.notifications mutableCopy];
    NSUInteger index = [self _mediaCellPresent] ? 1 : 0;
    [notifications insertObject:newNotification atIndex:index];

    // Update ivar
    _notifications = [notifications copy];

    // Update table
    void (^updateBlock)() = ^{
        [self.tableViewController.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    };

    if (@available(iOS 11, *)) {
        // Use the new and better performBatchUpdates
        [self.tableViewController.tableView performBatchUpdates:updateBlock completion:nil];
    } else {
        // Good old begin/endUpdates
        [self.tableViewController.tableView beginUpdates];

        updateBlock();

        [self.tableViewController.tableView endUpdates];
    }

    // Update height
    [self _resizeTableForExpansion:YES forNotification:YES];
}

- (void)notificationRepositoryUpdatedNotification:(NUACoalescedNotification *)updatedNotification removedRequest:(BOOL)removedRequest {
    if (!self.notifications) {
        // Notification shade hasnt been loaded
        return;
    }

    // Get old notification 
    NSMutableArray<NUACoalescedNotification *> *notifications = [self.notifications mutableCopy];
    NUACoalescedNotification *oldNotification = [self coalescedNotificationForSectionID:updatedNotification.sectionID threadID:updatedNotification.threadID];

    // Update expansion status
    if ([_expandedNotifications containsObject:oldNotification]) {
        [_expandedNotifications removeObject:oldNotification];
        [_expandedNotifications addObject:updatedNotification];
    }

    // Remove old and add new      
    NSUInteger oldIndex = [notifications indexOfObject:oldNotification];
    NSUInteger newIndex = 0;
    [notifications removeObject:oldNotification];
    if (removedRequest) {
        // Add and sort
        [notifications addObject:updatedNotification];

        // Sort via date
        [notifications sortUsingComparator:^(NUACoalescedNotification *notification1, NUACoalescedNotification *notification2) {
            return [notification2.timestamp compare:notification1.timestamp];
        }];

        newIndex = [notifications indexOfObject:updatedNotification];
    } else {
        // Simply add to top
        newIndex = [self _mediaCellPresent] ? 1 : 0;
    [notifications insertObject:updatedNotification atIndex:newIndex];
        }

    // Update ivar
    _notifications = [notifications copy];

    // Update table
        if (newIndex == oldIndex) {
            // Simply just reload the cell, no need to insert and delete
            [self.tableViewController.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:newIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }

    void (^updateBlock)() = ^{
            [self.tableViewController.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:oldIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableViewController.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:newIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    };

    if (@available(iOS 11, *)) {
        // Use the new and better performBatchUpdates
        [self.tableViewController.tableView performBatchUpdates:updateBlock completion:nil];
    } else {
        // Good old begin/endUpdates
        [self.tableViewController.tableView beginUpdates];

        updateBlock();

        [self.tableViewController.tableView endUpdates];
    }
}

- (void)notificationRepositoryRemovedNotification:(NUACoalescedNotification *)removedNotification {
    if (!self.notifications) {
        // Notification shade hasnt been loaded
        return;
    }

    // Update expansion status
    NUACoalescedNotification *oldNotification = [self coalescedNotificationForSectionID:removedNotification.sectionID threadID:removedNotification.threadID];
    [self notification:oldNotification shouldExpand:NO reload:NO];

    // Remove old
    NSMutableArray<NUACoalescedNotification *> *notifications = [self.notifications mutableCopy];
    NSUInteger oldIndex = [notifications indexOfObject:oldNotification];
    [notifications removeObject:oldNotification];

    // Update ivar
    _notifications = [notifications copy];

    // Update table
    void (^updateBlock)() = ^{
        [self.tableViewController.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:oldIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    };

    if (@available(iOS 11, *)) {
        // Use the new and better performBatchUpdates
        [self.tableViewController.tableView performBatchUpdates:updateBlock completion:nil];
    } else {
        // Good old begin/endUpdates
        [self.tableViewController.tableView beginUpdates];

        updateBlock();

        [self.tableViewController.tableView endUpdates];
    }

    // Update presented height
    [self _resizeTableForExpansion:NO forNotification:YES];
}

- (void)_resizeTableForExpansion:(BOOL)expand forNotification:(BOOL)forNotification {
    // Calculate current heights
    CGFloat proposedHeightToAdd = forNotification ? (expand ? 100.0 : -100.0) : (expand ? 50.0 : -50.0);
    CGFloat fullPanelHeight = [self.delegate tableViewControllerRequestsPanelContentHeight:self];
    CGFloat currentPanelHeight = ((fullPanelHeight - 150.0) * self.revealPercentage) + 150.0;
    CGFloat currentContentHeight = currentPanelHeight + self.contentHeight;
    CGFloat proposedNewHeight = currentContentHeight + proposedHeightToAdd;

    // Check if can expand/collapse
    CGFloat safeAreaHeight = kScreenHeight - 100.0;
    BOOL canExpand = currentContentHeight < safeAreaHeight;
    BOOL canCollapse = proposedNewHeight < safeAreaHeight;
    BOOL canResize = expand ? canExpand : canCollapse;
    if (!canResize) {
        // Any changes would be beyond safe area, return
        return;
    }

    // Calculate how much to add/subtract
    CGFloat expandableHeight = expand ? (safeAreaHeight - currentContentHeight) : (safeAreaHeight - proposedNewHeight);
    CGFloat actualHeightToAdd = MIN(fabs(proposedHeightToAdd), expandableHeight);
    actualHeightToAdd *= expand ? 1.0 : -1.0;

    // Animate
    [UIView animateWithDuration:0.4 animations:^{
        self.presentedHeight += actualHeightToAdd;
    }];
}

- (NUACoalescedNotification *)coalescedNotificationForSectionID:(NSString *)sectionID threadID:(NSString *)threadID {
    for (NUACoalescedNotification *notification in self.notifications) {
        if (![notification.sectionID isEqualToString:sectionID] || ![notification.threadID isEqualToString:threadID]) {
            // Make sure its the same notification
            continue;
        }

        return notification;
    }

    return nil;
}

- (NUACoalescedNotification *)notificationForIndexPath:(NSIndexPath *)indexPath {
    return self.notifications[indexPath.row];
}

- (NSIndexPath *)indexPathForNotification:(NUACoalescedNotification *)notification {
    // Get index from array and return
    NSUInteger index = [self.notifications indexOfObject:notification];
    return [NSIndexPath indexPathForRow:index inSection:0];
}

- (void)executeNotificationAction:(NSString *)type forCellAtIndexPath:(NSIndexPath *)indexPath {
    // Get associated entry
    NUACoalescedNotification *notification = [self notificationForIndexPath:indexPath];
    if (!notification || [notification isEqual:_mediaNotification]) {
        // Invalid notification
        return;
    }

    NUANotificationEntry *entry = notification.entries.firstObject;

    // Post to launch
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NUANotificationLaunchNotification" object:nil userInfo:@{@"type": type, @"request": entry.request}];

    if (![type isEqualToString:@"default"]) {
        return;
    }

        // Dismiss
        [self.delegate tableViewControllerWantsDismissal:self];
    }

#pragma mark - UIViewController

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    _heightConstraint = [view.heightAnchor constraintEqualToConstant:0.0];
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
    [center addObserver:self selector:@selector(_updateMedia) name:(__bridge_transfer NSString *)kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification object:nil];

    // Update media if needed
    [self _updateMedia];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // Stop listening for Notifs
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:(__bridge_transfer NSString *)kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification object:nil];

    // Remove media cell if needed
    [self removeMediaCellIfNecessary];
}

- (BOOL)_canShowWhileLocked {
    // New on iOS 13
    return YES;
}

#pragma mark - Notifications

- (void)_updateMedia {
    // Make sure on the main thread since the notification is dispatched on a mediaremote thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [self insertMediaCellIfNeccessary];
    });
}

#pragma mark - Media

- (BOOL)_mediaCellPresent {
    if (!self.notifications || self.notifications.count == 0) {
        // Cant check something that doesnt exist
        return NO;
    }

    // Since is always gonna be top notif, only check it
    NUACoalescedNotification *topNotification = self.notifications[0];
    return topNotification.type == NUANotificationTypeMedia;
}

- (void)insertMediaCellIfNeccessary {
    if ([self _mediaCellPresent] || !self.nowPlayingController.isPlaying || !self.notifications) {
        // cant add if already exists, or not playing, or if nothing to add to
        return;
    }

    // Add dummie to backng array
    NSMutableArray<NUACoalescedNotification *> *mutableNotifications = [self.notifications mutableCopy];
    [mutableNotifications insertObject:_mediaNotification atIndex:0];
    _notifications = [mutableNotifications copy];

    // Insert row
    void (^updateBlock)() = ^{
        [self.tableViewController.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    };

    if (@available(iOS 11, *)) {
        // Use the new and better performBatchUpdates
        [self.tableViewController.tableView performBatchUpdates:updateBlock completion:nil];
    } else {
        // Good old begin/endUpdates
        [self.tableViewController.tableView beginUpdates];

        updateBlock();

        [self.tableViewController.tableView endUpdates];
    }

    // Update presented height
    [self _resizeTableForExpansion:YES forNotification:YES];
}

- (void)removeMediaCellIfNecessary {
    if (![self _mediaCellPresent] || self.nowPlayingController.isPlaying) {
        // Cant remove something i dont have or cant remove something i need
        return;
    }

    // Remove media cell
    NSMutableArray<NUACoalescedNotification *> *mutableNotifications = [self.notifications mutableCopy];
    [mutableNotifications removeObjectAtIndex:0];
    _notifications = [mutableNotifications copy];

    // Delete row
    void (^updateBlock)() = ^{
        [self.tableViewController.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    };

    if (@available(iOS 11, *)) {
        // Use the new and better performBatchUpdates
        [self.tableViewController.tableView performBatchUpdates:updateBlock completion:nil];
    } else {
        // Good old begin/endUpdates
        [self.tableViewController.tableView beginUpdates];

        updateBlock();

        [self.tableViewController.tableView endUpdates];
    }

    // Update expansion status
    [self notification:_mediaNotification shouldExpand:NO reload:NO];

    // Update presented height
    [self _resizeTableForExpansion:NO forNotification:YES];
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
        NSString *nowPlayingID = self.nowPlayingController.nowPlayingAppDisplayID;
        if (!nowPlayingID) {
            // No now playing app
            return;
        }

        // Launch music playing app
        [(SpringBoard *)[UIApplication sharedApplication] launchApplicationWithIdentifier:nowPlayingID suspended:NO];

        // Dismiss nougat
        [self.delegate tableViewControllerWantsDismissal:self];
    } else {
        // Launch notif
        [self executeNotificationAction:@"default" forCellAtIndexPath:indexPath];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.notifications.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NUACoalescedNotification *notification = [self notificationForIndexPath:indexPath];
    if (notification.type == NUANotificationTypeMedia) {
        NUAMediaTableViewCell *mediaCell = [tableView dequeueReusableCellWithIdentifier:@"MediaCell" forIndexPath:indexPath];

        // Provide basic information
        mediaCell.delegate = self;
        mediaCell.expanded = [self isNotificationExpanded:notification];
        mediaCell.layoutMargins = UIEdgeInsetsZero;

        return mediaCell;
    }

    NUANotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCell" forIndexPath:indexPath];
    cell.notification = notification;
    cell.actionsDelegate = self;
    cell.delegate = self;
    cell.expanded = [self isNotificationExpanded:notification];
    cell.layoutMargins = UIEdgeInsetsZero;

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - Cells delegate

- (void)tableViewCell:(NUATableViewCell *)cell wantsExpansion:(BOOL)expand {
    // Get notification
    NUACoalescedNotification *notification; 
    if ([cell isKindOfClass:[NUAMediaTableViewCell class]]) {
        // Dealing with media class
        notification = _mediaNotification;
    } else {
        // Get cell's notification
        NUANotificationTableViewCell *notificationCell = (NUANotificationTableViewCell *)cell;
        notification = notificationCell.notification;
    }

    // Pass along
    [self notification:notification shouldExpand:expand reload:YES];
}

- (void)notification:(NUACoalescedNotification *)notification shouldExpand:(BOOL)expand reload:(BOOL)reload {
    // Add/remove
    if (expand && ![self isNotificationExpanded:notification]) {
        // Add to expanded
        [_expandedNotifications addObject:notification];

        // Update presented height
        [self _resizeTableForExpansion:YES forNotification:NO];

        if (!reload) {
            return;
        }

        // Reload
        NSIndexPath *indexPath = [self indexPathForNotification:notification];
        [self.tableViewController.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if (!expand && [self isNotificationExpanded:notification]) {
        // Add to expanded
        [_expandedNotifications removeObject:notification];

        // Update presented height
        [self _resizeTableForExpansion:NO forNotification:NO];

        if (!reload) {
            return;
        }

    // Reload
        NSIndexPath *indexPath = [self indexPathForNotification:notification];
        [self.tableViewController.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (BOOL)isNotificationExpanded:(NUACoalescedNotification *)notification {
    return [_expandedNotifications containsObject:notification];
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