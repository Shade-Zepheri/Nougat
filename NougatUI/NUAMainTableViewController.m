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

        // Notification stuffs
        _notificationRepository = [NUANotificationRepository defaultRepository];
    }

    return self;
}

- (UITableView *)_tableView {
    return self.tableViewController.tableView;
}

- (void)_populateTableView {
    // Load notifications form repo
    // NUACoalescedNotification *notif1 = [NUACoalescedNotification coalescedNotificationWithSectionID:@"com.apple.Preferences" title:@"Test1" message:@"This is a test" entires:nil];
    // NUACoalescedNotification *notif2 = [NUACoalescedNotification coalescedNotificationWithSectionID:@"com.atebits.Tweetie2" title:@"Test2" message:@"This is a test" entires:nil];

    NSArray<NUACoalescedNotification *> *notifications = self.notificationRepository.notifications.allValues;
    _notifications = notifications;
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
    [self _tableView].dataSource = self;
    [self _tableView].delegate = self;
    [self _tableView].translatesAutoresizingMaskIntoConstraints = NO;
    [self _tableView].tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:[self _tableView]];

    // // constraint up
    [[self _tableView].topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [[self _tableView].bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [[self _tableView].leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [[self _tableView].trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;

    // Register custom classes
    [self.tableViewController.tableView registerClass:[NUANotificationTableViewCell class] forCellReuseIdentifier:@"NotificationCell"];
    [self.tableViewController.tableView registerClass:[NUAMediaTableViewCell class] forCellReuseIdentifier:@"MediaCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Populate
    [self _populateTableView];

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
            UITableView *tableView = [self _tableView];
            [tableView beginUpdates];
            NSIndexPath *mediaIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [tableView deleteRowsAtIndexPaths:@[mediaIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
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
    return 150.0;
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
    // Test for now
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

- (void)insertCellForNotificationRequest:(id)request {
    // Not sure classes yet
}

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
    UITableView *tableView = [self _tableView];
    [tableView beginUpdates];
    NSIndexPath *mediaIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [tableView insertRowsAtIndexPaths:@[mediaIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    [tableView endUpdates];
}

@end