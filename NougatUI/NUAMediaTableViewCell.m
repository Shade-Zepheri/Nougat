#import "NUAMediaTableViewCell.h"
#import "Media/NUAMediaControlsView.h"
#import "Media/NUAMediaHeaderView.h"
#import "UIColor+Accent.h"
#import "UIImage+Average.h"
#import <MediaRemote/MediaRemote.h>
#import <SpringBoardServices/SpringBoardServices+Private.h>
#import <UIKit/UIImage+Private.h>

@interface NUAMediaTableViewCell ()
@property (strong, readonly, nonatomic) NUAPreferenceManager *settings;
@property (strong, readonly, nonatomic) MPUNowPlayingController *nowPlayingController;

@property (strong, nonatomic) UIImageView *artworkView;
@property (strong, nonatomic) CAGradientLayer *gradientLayer;
@property (strong, nonatomic) NUAMediaControlsView *controlsView;
@property (strong, nonatomic) NUAMediaHeaderView *headerView;

@property (strong, nonatomic) NSLayoutConstraint *controlsViewConstraint;

@property (strong, nonatomic) NSLayoutConstraint *controlsViewLeadingConstraint;
@property (strong, nonatomic) NSLayoutConstraint *controlsViewTrailingConstraint;
@property (strong, nonatomic) NSLayoutConstraint *headerViewTrailingConstraint;

@end

@implementation NUAMediaTableViewCell

#pragma mark - Initialization

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Settings
        _settings = [NUAPreferenceManager sharedSettings];

        // Register as delegate
        _nowPlayingController = [[NSClassFromString(@"MPUNowPlayingController") alloc] init];
        self.nowPlayingController.delegate = self;

        // Set properties
        self.metadata = self.nowPlayingController.currentNowPlayingMetadata;
        self.nowPlayingArtwork = self.nowPlayingController.currentNowPlayingArtwork;
        self.nowPlayingAppDisplayID = self.nowPlayingController.nowPlayingAppDisplayID;

        // Create views
        [self setupViews];
    }

    return self;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
    if (!object || ![object isKindOfClass:self.class]) {
        // Not same class
        return NO;
    }

    // TLDR: all media cells are the same since only one exists
    return YES;
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
    // Constrain the bad boys
    [self.artworkView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.artworkView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [self.artworkView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [self.artworkView.widthAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;

    [self.headerView.topAnchor constraintEqualToAnchor:self.headerLabel.bottomAnchor constant:6.0].active = YES;
    [self.headerView.leadingAnchor constraintEqualToAnchor:self.glyphView.leadingAnchor].active = YES;

    self.headerViewTrailingConstraint = [self.headerView.trailingAnchor constraintEqualToAnchor:self.artworkView.leadingAnchor constant:-10.0];
    self.headerViewTrailingConstraint.active = NO;

    self.controlsViewConstraint = [self.controlsView.bottomAnchor constraintEqualToAnchor:self.headerView.bottomAnchor constant:5.0];
    self.controlsViewConstraint.active = YES;

    self.controlsViewTrailingConstraint = [self.controlsView.trailingAnchor constraintEqualToAnchor:self.expandButton.trailingAnchor];
    self.controlsViewTrailingConstraint.active = YES;

    self.controlsViewLeadingConstraint = [self.controlsView.leadingAnchor constraintEqualToAnchor:self.headerView.leadingAnchor];
    self.controlsViewLeadingConstraint.active = NO;

    // Additional constraints
    [self.headerLabel.trailingAnchor constraintEqualToAnchor:self.artworkView.leadingAnchor constant:-10.0].active = YES;

    [self.contentView bringSubviewToFront:self.expandButton];
    [self.expandButton.topAnchor constraintEqualToAnchor:self.headerLabel.topAnchor].active = YES;
    [self.expandButton.leadingAnchor constraintEqualToAnchor:self.headerLabel.trailingAnchor constant:5.0].active = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    // Set bounds
    self.gradientLayer.frame = self.artworkView.bounds;
}

#pragma mark - Media views

- (void)_createArtworkView {
    self.artworkView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.artworkView.contentMode = UIViewContentModeScaleAspectFit;
    self.artworkView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.artworkView];
}

- (void)_createGradientView {
    UIView *gradientView = [[UIView alloc] initWithFrame:self.bounds];
    [self.artworkView addSubview:gradientView];

    [gradientView.topAnchor constraintEqualToAnchor:self.artworkView.topAnchor].active = YES;
    [gradientView.bottomAnchor constraintEqualToAnchor:self.artworkView.bottomAnchor].active = YES;
    [gradientView.leadingAnchor constraintEqualToAnchor:self.artworkView.leadingAnchor].active = YES;
    [gradientView.trailingAnchor constraintEqualToAnchor:self.artworkView.trailingAnchor].active = YES;

    // Create layer
    self.gradientLayer = [CAGradientLayer layer];
    UIColor *baseColor = [UIColor whiteColor];
    self.gradientLayer.colors = @[(id)baseColor.CGColor, (id)[baseColor colorWithAlphaComponent:0.85].CGColor, (id)[baseColor colorWithAlphaComponent:0.0].CGColor];
    self.gradientLayer.locations = @[@(0.0), @(0.5), @(1.0)];
    self.gradientLayer.startPoint = CGPointMake(0.0, 0.0);
    self.gradientLayer.endPoint = CGPointMake(1.0, 0.0);
    self.gradientLayer.frame = self.artworkView.bounds;
    [gradientView.layer addSublayer:self.gradientLayer];
}

- (void)_updateBackgroundGradientWithColor:(UIColor *)color {
    self.backgroundColor = color;
    self.gradientLayer.colors = @[(id)color.CGColor, (id)[color colorWithAlphaComponent:0.85].CGColor, (id)[color colorWithAlphaComponent:0.0].CGColor];

    // Update frame for good measure
    self.gradientLayer.frame = self.artworkView.bounds;
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

#pragma mark - Properties

- (void)setExpanded:(BOOL)expanded {
    [super setExpanded:expanded];

    self.headerView.expanded = expanded;
    self.controlsView.expanded = expanded;

    // Header constraints
    self.headerViewTrailingConstraint.active = expanded;

    // Controls constraints
    self.controlsViewConstraint.constant = expanded ? 55.0 : 5.0;
    self.controlsViewLeadingConstraint.active = expanded;
    self.controlsViewTrailingConstraint.active = !expanded;
}

- (BOOL)isPlaying {
    return self.nowPlayingController.isPlaying;
}

- (void)setNowPlayingArtwork:(UIImage *)nowPlayingArtwork {    
    _nowPlayingArtwork = nowPlayingArtwork;

    if (!nowPlayingArtwork) {
        return;
    }

    self.artworkView.image = nowPlayingArtwork;
    [self updateTintsFromImage:nowPlayingArtwork];
}

- (void)setNowPlayingAppDisplayID:(NSString *)nowPlayingAppDisplayID {
    _nowPlayingAppDisplayID = nowPlayingAppDisplayID;

    // Update imageview
    [self _updateHeaderLabelText];
    UIImage *appIcon = [UIImage _applicationIconImageForBundleIdentifier:nowPlayingAppDisplayID format:0 scale:[UIScreen mainScreen].scale];
    self.glyphView.image = appIcon;
}

- (void)setMetadata:(MPUNowPlayingMetadata *)metadata {
    _metadata = metadata;

    // Parse and pass to header
    self.headerView.artist = metadata.artist;
    self.headerView.song = metadata.title;

    // Update label
    [self _updateHeaderLabelText];
}

- (void)_updateTintsWithBackgroundColor:(UIColor *)backgroundColor tintColor:(UIColor *)tintColor {
    [self _updateBackgroundGradientWithColor:backgroundColor];

    // Set tint color
    self.headerLabel.textColor = tintColor;
    self.headerView.tintColor = tintColor;
    self.controlsView.tintColor = tintColor;

    // Update button
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UIImage *baseImage = [UIImage imageNamed:@"arrow-dark" inBundle:bundle];

    // Tint and set
    UIImage *tintedImage = [baseImage _flatImageWithColor:tintColor];
    [self.expandButton setImage:tintedImage forState:UIControlStateNormal];
}

#pragma mark - Info label

- (void)_updateHeaderLabelText {
    // Construct strings
    NSString *displayID = self.nowPlayingAppDisplayID ?: @"com.apple.Music";
    NSString *appDisplayName = SBSCopyLocalizedApplicationNameForDisplayIdentifier(displayID);
    NSString *baseText = [NSString stringWithFormat:@"%@ • %@", appDisplayName, self.metadata.album];

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:baseText];
    NSRange boldedRange = NSMakeRange(0, appDisplayName.length);
    UIFont *boldFont = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];

    // Add attributes
    [attributedString beginEditing];
    [attributedString addAttribute:NSFontAttributeName value:boldFont range:boldedRange];
    [attributedString endEditing];

    self.headerLabel.attributedText = [attributedString copy];
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
    });
}

#pragma mark - MPUNowPlayingDelegate

- (void)nowPlayingController:(MPUNowPlayingController *)controller nowPlayingInfoDidChange:(NSDictionary *)nowPlayingInfo {
    // Parse and pass on
    self.nowPlayingArtwork = controller.currentNowPlayingArtwork;
    self.metadata = controller.currentNowPlayingMetadata;
}

- (void)nowPlayingController:(MPUNowPlayingController *)controller playbackStateDidChange:(BOOL)isPlaying {
    // Pass to controls
    self.controlsView.playing = isPlaying;
}

- (void)nowPlayingController:(MPUNowPlayingController *)controller nowPlayingApplicationDidChange:(NSString *)nowPlayingAppDisplayID {
    // Pass to header
    self.nowPlayingAppDisplayID = nowPlayingAppDisplayID;
}

- (void)nowPlayingControllerDidBeginListeningForNotifications:(MPUNowPlayingController *)controller {
    // Do nothing
}

- (void)nowPlayingControllerDidStopListeningForNotifications:(MPUNowPlayingController *)controller {
    // Do nothing
}

- (void)nowPlayingController:(MPUNowPlayingController *)controller elapsedTimeDidChange:(double)elapsedTime {
    // Do nothing
}

#pragma mark - Default Color Provider

- (void)updateTintsFromImage:(UIImage *)artworkImage {
    if (self.settings.useExternalColor) {
        // Dont use our method if user wants colorflow
        [self updateTintsUsingColorfow:artworkImage];
    } else {
        // Use built in methods
        UIColor *backgroundColor = artworkImage.averageColor;
        UIColor *tintColor = backgroundColor.accentColor;

        [self _updateTintsWithBackgroundColor:backgroundColor tintColor:tintColor];
    }
}

#pragma mark - Colorflow

- (void)updateTintsUsingColorfow:(UIImage *)artworkImage {
    AnalyzedInfo info = [NSClassFromString(@"CFWBucket") analyzeImage:artworkImage resize:YES];
    CFWColorInfo *colorInfo = [NSClassFromString(@"CFWColorInfo") colorInfoWithAnalyzedInfo:info];

    [self _updateTintsWithBackgroundColor:colorInfo.backgroundColor tintColor:colorInfo.primaryColor];
}

@end