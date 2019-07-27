#import "NUAMainTableViewController.h"
#import "NUAMediaTableViewCell.h"
#import "NUANotificationTableViewCell.h"
#import <MediaRemote/MediaRemote.h>

@implementation NUAMainTableViewController

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
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
        return;
    }

    // Generate only once
    NSDictionary<NSString *, NSArray<NUACoalescedNotification *> *> *notificationsEntries = self.notificationRepository.notifications;
    NSMutableArray<NUACoalescedNotification *> *notifications = [NSMutableArray array];
    for (NSArray<NUACoalescedNotification *> *notificationGroups in notificationsEntries.allValues) {
        // Add all entries from each array
        [notifications addObjectsFromArray:notificationGroups];
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

#pragma mark - Observer

- (void)notificationRepositoryAddedNotification:(NUACoalescedNotification *)newNotification {
    if (!_notifications) {
        [self _loadNotificationsIfNecessary];
    }

    // Add new entry
    NSMutableArray<NUACoalescedNotification *> *notifications = [_notifications mutableCopy];
    [notifications insertObject:newNotification atIndex:0];

    // Update ivar
    _notifications = [notifications copy];

    // Update table
    [self.tableViewController.tableView beginUpdates];

    [self.tableViewController.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];

    [self.tableViewController.tableView endUpdates];
}

- (void)notificationRepositoryUpdatedNotification:(NUACoalescedNotification *)updatedNotification {
    if (!_notifications) {
        [self _loadNotificationsIfNecessary];
    }

    // Get old notification 
    NSMutableArray<NUACoalescedNotification *> *notifications = [_notifications mutableCopy];
    NUACoalescedNotification *oldNotification = [self _notificationForSectionID:updatedNotification.sectionID threadID:updatedNotification.threadID];

    // Remove old and add new      
    NSUInteger oldIndex = [notifications indexOfObject:oldNotification];
    [notifications removeObject:oldNotification];
    [notifications insertObject:updatedNotification atIndex:0];

    // Update ivar
    _notifications = [notifications copy];

    // Update table
    [self.tableViewController.tableView beginUpdates];

    [self.tableViewController.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:oldIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableViewController.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];

    [self.tableViewController.tableView endUpdates];
}

- (NUACoalescedNotification *)_notificationForSectionID:(NSString *)sectionID threadID:(NSString *)threadID {
    for (NUACoalescedNotification *notification in _notifications) {
        if (![notification.sectionID isEqualToString:sectionID] || ![notification.threadID isEqualToString:threadID]) {
            // Make sure its the same notification
            continue;
        }

        return notification;
    }

    return nil;
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
    self.tableViewController.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableViewController.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableViewController.tableView];

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

    // Populate
    [self _loadNotificationsIfNecessary];

    // Register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_updateMedia) name:(__bridge_transfer NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification object:nil];
    [self _updateMedia];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // Deregister from notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:(__bridge_transfer NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification object:nil];
}

#pragma mark - Media

- (void)_updateMedia {
    if (!self.nowPlayingController.isPlaying) {
        // No need to do anything
        if ([self _mediaCellPresent]) {
            // Remove dummie
            NSMutableArray<NUACoalescedNotification *> *mutableNotifications = [_notifications mutableCopy];
            [mutableNotifications removeObjectAtIndex:0];
            _notifications = [mutableNotifications copy];

            // Remove media cell
            [self.tableViewController.tableView beginUpdates];
            NSIndexPath *mediaIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableViewController.tableView deleteRowsAtIndexPaths:@[mediaIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableViewController.tableView endUpdates];
        }

        return;
    }

    [self insertMediaCellIfNeccessary];
}

- (BOOL)_mediaCellPresent {
    for (NUACoalescedNotification *notification in _notifications) {
        if (notification.type != NUANotificationTypeMedia) {
            continue;
        }

        return YES;
    }

    return NO;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Temporary for testing
    return _notifications.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NUACoalescedNotification *notification = _notifications[indexPath.row];
    if (notification.type == NUANotificationTypeMedia) {
        NUAMediaTableViewCell *mediaCell = [tableView dequeueReusableCellWithIdentifier:@"MediaCell"];

        // Provide basic information
        mediaCell.nowPlayingArtwork = self.nowPlayingController.currentNowPlayingArtwork;
        mediaCell.nowPlayingAppDisplayID = self.nowPlayingController.nowPlayingAppDisplayID;
        mediaCell.metadata = self.nowPlayingController.currentNowPlayingMetadata;

        return mediaCell;
    }

    NUANotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCell"];
    cell.notification = notification;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - Cells Delegate


#pragma mark - Cells

- (void)insertMediaCellIfNeccessary {
    if ([self _mediaCellPresent]) {
        return;
    }

    // Add dummie to backng array
    NSMutableArray<NUACoalescedNotification *> *mutableNotifications = [_notifications mutableCopy];
    NUACoalescedNotification *mediaNotification = [NUACoalescedNotification mediaNotification];
    [mutableNotifications insertObject:mediaNotification atIndex:0];
    _notifications = [mutableNotifications copy];

    // Insert at top
    [self.tableViewController.tableView beginUpdates];
    NSIndexPath *mediaIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableViewController.tableView insertRowsAtIndexPaths:@[mediaIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableViewController.tableView endUpdates];
}

@end