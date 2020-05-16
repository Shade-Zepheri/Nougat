#import "NUAMediaTableViewCell.h"
#import "NUAImageColorCache.h"
#import "Media/NUAMediaControlsView.h"
#import "Media/NUAMediaHeaderView.h"
#import <MediaRemote/MediaRemote.h>
#import <MobileCoreServices/LSApplicationProxy.h>
#import <UIKit/UIImage+Private.h>

@interface NUAMediaTableViewCell ()
@property (strong, readonly, nonatomic) MPUNowPlayingController *nowPlayingController;
@property (strong, nonatomic) NSLayoutConstraint *heightConstraint;

@property (strong, nonatomic) UIImageView *artworkView;
@property (strong, nonatomic) CAGradientLayer *gradientLayer;
@property (strong, nonatomic) UILabel *albumLabel;
@property (strong, nonatomic) NUAMediaControlsView *controlsView;
@property (strong, nonatomic) NUAMediaHeaderView *headerView;

@property (strong, nonatomic) NSLayoutConstraint *controlsViewCollapsedTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint *controlsViewExpandedTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint *controlsViewLeadingConstraint;
@property (strong, nonatomic) NSLayoutConstraint *controlsViewTrailingConstraint;
@property (strong, nonatomic) NSLayoutConstraint *headerViewDefaultTrailingConstraint;
@property (strong, nonatomic) NSLayoutConstraint *headerViewExpandedTrailingConstraint;

@end

@implementation NUAMediaTableViewCell

#pragma mark - Initialization

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Register as delegate
        _nowPlayingController = [[NSClassFromString(@"MPUNowPlayingController") alloc] init];
        self.nowPlayingController.delegate = self;

        // Set properties
        self.metadata = self.nowPlayingController.currentNowPlayingMetadata;
        self.nowPlayingArtwork = self.nowPlayingController.currentNowPlayingArtwork;
        self.nowPlayingAppDisplayID = self.nowPlayingController.nowPlayingAppDisplayID;

        _heightConstraint = [self.contentView.heightAnchor constraintEqualToConstant:90.0];
        _heightConstraint.active = YES;

        // Create views
        [self setupViews];
    }

    return self;
}

#pragma mark - View Creation

- (void)setupViews {
    [self _createArtworkView];
    [self _createGradientView];
    [self _createHeaderView];
    [self _createControlsView];

    // Constraints
    [self setupConstraints];
}

- (void)setupConstraints {
    // Header constraints
    [self.headerView.topAnchor constraintEqualToAnchor:self.headerStackView.bottomAnchor constant:6.0].active = YES;
    [self.headerView.leadingAnchor constraintEqualToAnchor:self.headerStackView.leadingAnchor].active = YES;

    self.headerViewDefaultTrailingConstraint = [self.headerView.trailingAnchor constraintLessThanOrEqualToAnchor:self.controlsView.leadingAnchor constant:-10.0];
    self.headerViewDefaultTrailingConstraint.active = YES;

    self.headerViewExpandedTrailingConstraint = [self.headerView.trailingAnchor constraintLessThanOrEqualToAnchor:self.artworkView.leadingAnchor constant:-10.0];
    self.headerViewExpandedTrailingConstraint.active = NO;

    // Finish expand button constraints
    [self.headerStackView.trailingAnchor constraintLessThanOrEqualToAnchor:self.artworkView.leadingAnchor constant:-10.0].active = YES;

    // Controls view constraints
    self.controlsViewCollapsedTopConstraint = [self.controlsView.topAnchor constraintEqualToAnchor:self.headerView.topAnchor];
    self.controlsViewCollapsedTopConstraint.active = YES;

    self.controlsViewExpandedTopConstraint = [self.controlsView.topAnchor constraintEqualToAnchor:self.headerView.bottomAnchor constant:5.0];
    self.controlsViewExpandedTopConstraint.active = NO;

    self.controlsViewLeadingConstraint = [self.controlsView.leadingAnchor constraintEqualToAnchor:self.headerView.leadingAnchor];
    self.controlsViewLeadingConstraint.active = NO;

    self.controlsViewTrailingConstraint = [self.controlsView.trailingAnchor constraintEqualToAnchor:self.artworkView.leadingAnchor];
    self.controlsViewTrailingConstraint.active = YES;

    // Set expandable
    self.expandable = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    // Set bounds
    self.gradientLayer.frame = self.artworkView.bounds;
}

#pragma mark - Media Views

- (void)_createArtworkView {
    self.artworkView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.artworkView.contentMode = UIViewContentModeScaleAspectFit;
    self.artworkView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.artworkView];

    // Constraints
    [self.artworkView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor].active = YES;
    [self.artworkView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor].active = YES;
    [self.artworkView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor].active = YES;
    [self.artworkView.widthAnchor constraintEqualToAnchor:self.contentView.heightAnchor].active = YES;
}

- (void)_createGradientView {
    // Create layer
    self.gradientLayer = [CAGradientLayer layer];
    UIColor *baseColor = [UIColor whiteColor];
    self.gradientLayer.colors = @[(id)baseColor.CGColor, (id)[baseColor colorWithAlphaComponent:0.85].CGColor, (id)[baseColor colorWithAlphaComponent:0.0].CGColor];
    self.gradientLayer.locations = @[@(0.0), @(0.5), @(1.0)];
    self.gradientLayer.startPoint = CGPointMake(0.0, 0.0);
    self.gradientLayer.endPoint = CGPointMake(1.0, 0.0);
    self.gradientLayer.frame = self.artworkView.bounds;
    [self.artworkView.layer addSublayer:self.gradientLayer];
}

- (void)_createHeaderView {
    // These are pretty short
    self.headerView = [[NUAMediaHeaderView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.headerView];
}

- (void)_createControlsView {
    self.controlsView = [[NUAMediaControlsView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.controlsView];
}

#pragma mark - UITableViewCell 

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];

    // Change album artwork alpha
    self.artworkView.alpha = highlighted ? 0.23 : 1.0;
}

#pragma mark - Properties

- (void)setExpanded:(BOOL)expanded {
    [super setExpanded:expanded];

    self.heightConstraint.constant = expanded ? 135.0 : 90.0;

    self.controlsView.expanded = expanded;

    // Header constraints
    self.headerViewDefaultTrailingConstraint.active = !expanded;
    self.headerViewExpandedTrailingConstraint.active = expanded;

    // Controls constraints
    self.controlsViewCollapsedTopConstraint.active = !expanded;
    self.controlsViewExpandedTopConstraint.active = expanded;
    self.controlsViewLeadingConstraint.active = expanded;
    self.controlsViewTrailingConstraint.active = !expanded;
    [self setNeedsLayout];
}

- (BOOL)isPlaying {
    return self.controlsView.playing;
}

- (void)setPlaying:(BOOL)playing {
    if (playing == self.playing) {
        return;
    }

    // Pass to controls
    self.controlsView.playing = playing;
    [self setNeedsLayout];
}

- (void)setNowPlayingArtwork:(UIImage *)nowPlayingArtwork {    
    _nowPlayingArtwork = nowPlayingArtwork;

    if (!nowPlayingArtwork) {
        return;
    }

    self.artworkView.image = nowPlayingArtwork;
    [self updateTintsFromImage:nowPlayingArtwork];
    [self setNeedsLayout];
}

- (void)setNowPlayingAppDisplayID:(NSString *)nowPlayingAppDisplayID {
    _nowPlayingAppDisplayID = nowPlayingAppDisplayID;

    // Update imageview
    [self _updateHeaderLabelText];
    self.headerGlyph = [UIImage _applicationIconImageForBundleIdentifier:nowPlayingAppDisplayID format:0 scale:[UIScreen mainScreen].scale];
    [self setNeedsLayout];
}

- (void)setMetadata:(MPUNowPlayingMetadata *)metadata {
    _metadata = metadata;

    // Parse and pass to header
    self.headerView.artist = metadata.artist;
    self.headerView.song = metadata.title;

    // Update label
    [self _updateHeaderLabelText];
    [self setNeedsLayout];
}

#pragma mark - Info label

- (void)_updateHeaderLabelText {
    // Get app display name
    NSString *identifier = self.nowPlayingAppDisplayID ?: @"com.apple.Music";
    LSApplicationProxy *applicationProxy = [NSClassFromString(@"LSApplicationProxy") applicationProxyForIdentifier:identifier];
    NSString *appDisplayName = applicationProxy.localizedName;
    self.headerText = appDisplayName;

    // Set album name
    [self _createAlbumLabelIfNecessary];
    self.albumLabel.text = self.metadata.album;
}

- (void)_createAlbumLabelIfNecessary {
    if (self.albumLabel) {
        return;
    }

    // Create label
    _albumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.albumLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.albumLabel.textColor = [UIColor grayColor];
    self.albumLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [self.albumLabel.heightAnchor constraintEqualToConstant:18.0].active = YES;

    // Add to stack
    [self.headerStackView insertArrangedSubview:self.albumLabel atIndex:3];
}

#pragma mark - Notifications

- (void)registerForMediaNotifications {
    // Register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMedia) name:(__bridge_transfer NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification object:nil];
    [self.nowPlayingController _registerForNotifications];

    // Update media info
    [self updateMedia];
}

- (void)unregisterForMediaNotifications {
    // Unregister for notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:(__bridge_transfer NSString *)kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification object:nil];
    [self.nowPlayingController _unregisterForNotifications];
}

- (void)updateMedia {
    // Make sure on the main thread since the notification is dispatched on a mediaremote thread
    dispatch_async(dispatch_get_main_queue(), ^{
        // Pass down info
        self.nowPlayingArtwork = self.nowPlayingController.currentNowPlayingArtwork;
        self.metadata = self.nowPlayingController.currentNowPlayingMetadata;
        self.nowPlayingAppDisplayID = self.nowPlayingController.nowPlayingAppDisplayID;
        self.playing = self.nowPlayingController.isPlaying;
    });
}

#pragma mark - MPUNowPlayingDelegate

- (void)nowPlayingController:(MPUNowPlayingController *)controller nowPlayingInfoDidChange:(NSDictionary *)nowPlayingInfo {
    // Ensure on the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        // Parse and pass on
        self.nowPlayingArtwork = controller.currentNowPlayingArtwork;
        self.metadata = controller.currentNowPlayingMetadata;
    });
}

- (void)nowPlayingController:(MPUNowPlayingController *)controller playbackStateDidChange:(BOOL)isPlaying {
    // Ensure on the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        // Pass to controls
        self.playing = isPlaying;
    });
}

- (void)nowPlayingController:(MPUNowPlayingController *)controller nowPlayingApplicationDidChange:(NSString *)nowPlayingAppDisplayID {
    // Ensure on the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        // Pass to header
        self.nowPlayingAppDisplayID = nowPlayingAppDisplayID;
    });
}

- (void)nowPlayingControllerDidBeginListeningForNotifications:(MPUNowPlayingController *)controller {
    // Do nothing
    return;
}

- (void)nowPlayingControllerDidStopListeningForNotifications:(MPUNowPlayingController *)controller {
    // Do nothing
    return;
}

- (void)nowPlayingController:(MPUNowPlayingController *)controller elapsedTimeDidChange:(double)elapsedTime {
    // Do nothing
    return;
}

#pragma mark - Colors

- (void)updateTintsFromImage:(UIImage *)artworkImage {
    if (self.notificationShadePreferences.useExternalColor && NSClassFromString(@"CFWBucket")) {
        // Only use colorflow if it exists and selected
        [self updateTintsUsingColorfow:artworkImage];
    } else {
        // Use built in methods
        [self updateTintsUsingCache:artworkImage];
    }
}

- (void)updateTintsUsingCache:(UIImage *)artworkImage {
    // Use our own cache
    NUAImageColorCache *colorCache = [NUAImageColorCache sharedCache];
    if ([colorCache hasColorDataForImage:artworkImage type:NUAImageColorInfoTypeAlbumArtwork]) {
        // Has data
        NUAImageColorInfo *colorInfo = [colorCache cachedColorInfoForImage:artworkImage type:NUAImageColorInfoTypeAlbumArtwork];
        [self _updateTintsWithBackgroundColor:colorInfo.primaryColor tintColor:colorInfo.accentColor];
    } else {
        // Generate
        [colorCache cacheColorInfoForImage:artworkImage type:NUAImageColorInfoTypeAlbumArtwork completion:^(NUAImageColorInfo *colorInfo) {
            [self _updateTintsWithBackgroundColor:colorInfo.primaryColor tintColor:colorInfo.accentColor];
        }];
    }
}

- (void)_updateTintsWithBackgroundColor:(UIColor *)backgroundColor tintColor:(UIColor *)tintColor {
    [self _updateBackgroundGradientWithColor:backgroundColor];

    // Set tint color
    self.headerTint = tintColor;
    self.albumLabel.textColor = tintColor;
    self.headerView.tintColor = tintColor;
    self.controlsView.tintColor = tintColor;
}

- (void)_updateBackgroundGradientWithColor:(UIColor *)color {
    self.backgroundColor = color;
    self.gradientLayer.colors = @[(id)color.CGColor, (id)[color colorWithAlphaComponent:0.85].CGColor, (id)[color colorWithAlphaComponent:0.0].CGColor];

    // Update frame for good measure
    self.gradientLayer.frame = self.artworkView.bounds;
}

#pragma mark - ColorFlow

- (void)updateTintsUsingColorfow:(UIImage *)artworkImage {
    AnalyzedInfo info = [NSClassFromString(@"CFWBucket") analyzeImage:artworkImage resize:YES];
    CFWColorInfo *colorInfo = [NSClassFromString(@"CFWColorInfo") colorInfoWithAnalyzedInfo:info];

    [self _updateTintsWithBackgroundColor:colorInfo.backgroundColor tintColor:colorInfo.primaryColor];
}

@end