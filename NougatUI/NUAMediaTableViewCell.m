#import "NUAMediaTableViewCell.h"
#import "Media/NUAMediaControlsView.h"
#import "Media/NUAMediaHeaderView.h"
#import "UIColor+Accent.h"
#import "UIImage+Average.h"
#import <MediaRemote/MediaRemote.h>
#import <UIKit/UIImage+Private.h>

@interface NUAMediaTableViewCell ()
@property (strong, nonatomic) UIImageView *artworkView;
@property (strong, nonatomic) CAGradientLayer *gradientLayer;
@property (strong, nonatomic) NUAMediaControlsView *controlsView;
@property (strong, nonatomic) NUAMediaHeaderView *headerView;
@property (strong, nonatomic) UIButton *expandButton;

@end

@implementation NUAMediaTableViewCell

#pragma mark - Initialization

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Register as delegate
        _nowPlayingController = [[NSClassFromString(@"MPUNowPlayingController") alloc] init];
        self.nowPlayingController.delegate = self;

        // Register for notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMedia) name:(__bridge_transfer NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification object:nil];
        [self.nowPlayingController _registerForNotifications];

        // Update
        [self updateMedia];
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    // Create views if needed
    [self _createArtworkViewIfNecessary];
    [self _createGradientViewIfNecessary];
    [self _createHeaderViewIfNecessary];
    [self _createControlsViewIfNecessary];
    [self _createExpandButtonIfNecessary];

    // Set bounds
    self.gradientLayer.frame = self.artworkView.bounds;
}

#pragma mark - Media views

- (void)_createArtworkViewIfNecessary {
    if (self.artworkView) {
        return;
    }

    self.artworkView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.artworkView.contentMode = UIViewContentModeScaleAspectFit;
    self.artworkView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.artworkView];

    [self.artworkView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.artworkView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [self.artworkView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [self.artworkView.widthAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;
 }

- (void)_createGradientViewIfNecessary {
    if (self.gradientLayer) {
        return;
    }

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

- (void)_createHeaderViewIfNecessary {
    if (self.headerView) {
        return;
    }

    self.headerView = [[NUAMediaHeaderView alloc] initWithFrame:CGRectZero];
    self.headerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.headerView];

    [self.headerView.topAnchor constraintEqualToAnchor:self.topAnchor constant:12.0].active = YES;
    [self.headerView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:12.0].active = YES;
    [self.headerView.trailingAnchor constraintEqualToAnchor:self.artworkView.leadingAnchor constant:-10.0].active = YES;
}

- (void)_createControlsViewIfNecessary {
    if (self.controlsView) {
        return;
    }

    self.controlsView = [[NUAMediaControlsView alloc] initWithFrame:CGRectZero];
    self.controlsView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.controlsView];

    [self.controlsView.topAnchor constraintEqualToAnchor:self.headerView.topAnchor constant:5.0].active = YES;
    [self.controlsView.trailingAnchor constraintEqualToAnchor:self.artworkView.leadingAnchor].active = YES;
}

- (void)_createExpandButtonIfNecessary {
    self.expandButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.expandButton addTarget:self action:@selector(_expandCell:) forControlEvents:UIControlEventTouchUpInside];
    self.expandButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.expandButton];

    [self.expandButton.topAnchor constraintEqualToAnchor:self.headerView.topAnchor].active = YES;
    [self.expandButton.leadingAnchor constraintEqualToAnchor:self.headerView.trailingAnchor constant:5.0].active = YES;
    [self.expandButton.heightAnchor constraintEqualToConstant:18.0].active = YES;
    [self.expandButton.widthAnchor constraintEqualToConstant:18.0].active = YES;
}

#pragma mark - Button

- (void)_expandCell:(UIButton *)sender {
    // Little trick for flip
    _expanded = !_expanded;


    // Notify table
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NUATableCellWantsReloadNotification" object:nil userInfo:nil];

    // Force layout
    [self setNeedsLayout];

    // Flip image
    CGFloat angle = M_PI * [@(_expanded) intValue];
    [UIView transitionWithView:self.imageView duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        sender.imageView.transform = CGAffineTransformMakeRotation(angle);
    } completion:nil];
}

#pragma mark - Properties

- (BOOL)isPlaying {
    return self.nowPlayingController.isPlaying;
}

- (void)setNowPlayingArtwork:(UIImage *)nowPlayingArtwork {    
    _nowPlayingArtwork = nowPlayingArtwork;

    if (!nowPlayingArtwork) {
        return;
    }

    self.artworkView.image = nowPlayingArtwork;
    [self _updateTintsForArtwork:nowPlayingArtwork];
}

- (void)setNowPlayingAppDisplayID:(NSString *)nowPlayingAppDisplayID {
    _nowPlayingAppDisplayID = nowPlayingAppDisplayID;

    // Pass to header
    self.headerView.nowPlayingApp = nowPlayingAppDisplayID;
}

- (void)setMetadata:(MPUNowPlayingMetadata *)metadata {
    _metadata = metadata;

    // Parse and pass to header
    self.headerView.album = metadata.album;
    self.headerView.artist = metadata.artist;
    self.headerView.song = metadata.title;
}

- (void)_updateTintsForArtwork:(UIImage *)artwork {
    UIColor *averageColor = artwork.averageColor;
    [self _updateBackgroundGradientWithColor:averageColor];

    // Set tint color
    UIColor *accentColor = averageColor.accentColor;
    self.headerView.tintColor = accentColor;
    self.controlsView.tintColor = accentColor;

    // Update button
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UIImage *baseImage = [UIImage imageNamed:@"arrow-dark" inBundle:bundle];

    // Tint and set
    UIImage *tintedImage = [baseImage _flatImageWithColor:accentColor];
    [self.expandButton setImage:tintedImage forState:UIControlStateNormal];
}

#pragma mark - Notifications

- (void)updateMedia {
    // Pass to view
    self.nowPlayingArtwork = self.nowPlayingController.currentNowPlayingArtwork;
    self.metadata = self.nowPlayingController.currentNowPlayingMetadata;
    self.nowPlayingAppDisplayID = self.nowPlayingController.nowPlayingAppDisplayID;
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
    self.headerView.nowPlayingApp = nowPlayingAppDisplayID;
}

- (void)nowPlayingControllerDidBeginListeningForNotifications:(MPUNowPlayingController *)controller {

}

- (void)nowPlayingControllerDidStopListeningForNotifications:(MPUNowPlayingController *)controller {

}

- (void)nowPlayingController:(MPUNowPlayingController *)controller elapsedTimeDidChange:(double)elapsedTime {

}

@end