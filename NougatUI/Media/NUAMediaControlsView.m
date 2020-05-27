#import "NUAMediaControlsView.h"
#import <MediaRemote/MediaRemote.h>
#import <UIKit/UIImage+Private.h>

@interface NUAMediaControlsView ()
@property (strong, nonatomic) UIStackView *stackView;
@property (strong, nonatomic) UIButton *skipButton;
@property (strong, nonatomic) UIButton *rewindButton;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) UIButton *likeButton;
@property (strong, nonatomic) UIButton *dislikeButton;

@end

@implementation NUAMediaControlsView

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Defaults
        _expanded = NO;
        _playing = NO;
        _supportsLiking = NO;
        _liked = NO;
        _disliked = NO;

        // Constraint up
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self.heightAnchor constraintEqualToConstant:48.0].active = YES;

        // Create views
        [self createArrangedViews];

        // Stacc attacc
        self.stackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.likeButton, self.rewindButton, self.playButton, self.skipButton, self.dislikeButton]];
        self.stackView.axis = UILayoutConstraintAxisHorizontal;
        self.stackView.alignment = UIStackViewAlignmentCenter;
        self.stackView.distribution = UIStackViewDistributionEqualSpacing;
        self.stackView.spacing = 10.0;
        self.stackView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.stackView];

        // Constrain our width
        [self.widthAnchor constraintEqualToAnchor:self.stackView.widthAnchor].active = YES;

        // Constrain the stacc
        [self.stackView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [self.stackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
        [self.stackView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    }

    return self;
}

- (void)createArrangedViews {
    // Controls
    self.likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.likeButton addTarget:self action:@selector(likeTrack) forControlEvents:UIControlEventTouchUpInside];
    UIImage *likeButtonImage = [[UIImage imageNamed:@"Like" inBundle:[NSBundle bundleForClass:self.class]] _flatImageWithColor:[UIColor whiteColor]];
    [self.likeButton setImage:likeButtonImage forState:UIControlStateNormal];
    self.likeButton.hidden = YES;

    self.rewindButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rewindButton addTarget:self action:@selector(rewindTrack) forControlEvents:UIControlEventTouchUpInside];
    UIImage *rewindButtonImage = [[UIImage imageNamed:@"Rewind" inBundle:[NSBundle bundleForClass:self.class]] _flatImageWithColor:[UIColor whiteColor]];
    [self.rewindButton setImage:rewindButtonImage forState:UIControlStateNormal];

    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playButton addTarget:self action:@selector(playPauseTrack) forControlEvents:UIControlEventTouchUpInside];
    UIImage *playButtonImage = [[UIImage imageNamed:@"Play" inBundle:[NSBundle bundleForClass:self.class]] _flatImageWithColor:[UIColor whiteColor]];
    [self.playButton setImage:playButtonImage forState:UIControlStateNormal];

    self.skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.skipButton addTarget:self action:@selector(skipTrack) forControlEvents:UIControlEventTouchUpInside];
    UIImage *skipButtonImage = [[UIImage imageNamed:@"Skip" inBundle:[NSBundle bundleForClass:self.class]] _flatImageWithColor:[UIColor whiteColor]];
    [self.skipButton setImage:skipButtonImage forState:UIControlStateNormal];

    self.dislikeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.dislikeButton addTarget:self action:@selector(dislikeTrack) forControlEvents:UIControlEventTouchUpInside];
    UIImage *dislikeButtonImage = [[UIImage imageNamed:@"Dislike" inBundle:[NSBundle bundleForClass:self.class]] _flatImageWithColor:[UIColor whiteColor]];
    [self.dislikeButton setImage:dislikeButtonImage forState:UIControlStateNormal];
    self.dislikeButton.hidden = YES;
}

#pragma mark - Properties

- (void)setExpanded:(BOOL)expanded {
    _expanded = expanded;

    // Show buttons
    if (self.supportsLiking) {
        self.likeButton.hidden = !expanded;
        self.dislikeButton.hidden = !expanded;
    }

    [self setNeedsLayout];
}

- (void)setPlaying:(BOOL)playing {
    if (playing == _playing) {
        // No change
        return;
    }

    _playing = playing;

    // Update views
    [self _updatePlayPauseImage:YES];
}

- (void)setLiked:(BOOL)liked {
    if (liked == _liked) {
        // No change
        return;
    }

    _liked = liked;

    // Update views
    [self _updateLikedImage:liked];
}

- (void)setDisliked:(BOOL)disliked {
    if (disliked == _disliked) {
        // No change
        return;
    }

    // Yes, disliked and liked require 2 separate states
    _disliked = disliked;

    // Update views
    [self _updateDislikedImage:disliked];
}

- (void)setTintColor:(UIColor *)color {
    _tintColor = color;

    // Colorize images
    UIImage *skipButtonImage = [[UIImage imageNamed:@"Skip" inBundle:[NSBundle bundleForClass:self.class]] _flatImageWithColor:color];
    [self.skipButton setImage:skipButtonImage forState:UIControlStateNormal];

    UIImage *rewindButtonImage = [[UIImage imageNamed:@"Rewind" inBundle:[NSBundle bundleForClass:self.class]] _flatImageWithColor:color];
    [self.rewindButton setImage:rewindButtonImage forState:UIControlStateNormal];

    // Simply call helper methods
    [self _updateLikedImage:self.liked];
    [self _updateDislikedImage:self.disliked];

    // Color play
    [self _updatePlayPauseImage:NO];
}

#pragma mark - Image Management

- (void)_updateLikedImage:(BOOL)liked {
    // Get liked image
    NSBundle *resourceBundle = [NSBundle bundleForClass:self.class];
    NSString *likedImageName = liked ? @"Liked-Filled" : @"Liked-Outline";
    UIImage *baseLikedImage = [UIImage imageNamed:likedImageName inBundle:resourceBundle];
    UIImage *tintedLikedImage = [baseLikedImage _flatImageWithColor:self.tintColor];
    [self.likeButton setImage:tintedLikedImage forState:UIControlStateNormal];
}

- (void)_updateDislikedImage:(BOOL)disliked {
    // Get new image
    NSBundle *resourceBundle = [NSBundle bundleForClass:self.class];
    NSString *dislikedImageName = disliked ? @"Disliked-Filled" : @"Disliked-Outline";
    UIImage *baseDislikedImage = [UIImage imageNamed:dislikedImageName inBundle:resourceBundle];
    UIImage *tintedDislikedImage = [baseDislikedImage _flatImageWithColor:self.tintColor];
    [self.dislikeButton setImage:tintedDislikedImage forState:UIControlStateNormal];
}

- (void)_updatePlayPauseImage:(BOOL)animated {
    // Get new image
    NSString *imageName = self.playing ? @"Pause" : @"Play";
    UIImage *baseImage = [UIImage imageNamed:imageName inBundle:[NSBundle bundleForClass:self.class]];
    UIImage *tintedImage = [baseImage _flatImageWithColor:self.tintColor];

    // Animate
    CGFloat duration = animated ? 0.3 : 0.0;
    [UIView transitionWithView:self.playButton duration:duration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self.playButton setImage:tintedImage forState:UIControlStateNormal];
    } completion:nil];
}

#pragma mark - Actions

- (void)rewindTrack {
    MRMediaRemoteSendCommand(MRMediaRemoteCommandPreviousTrack, nil);
}

- (void)playPauseTrack {
    MRMediaRemoteCommand command = self.playing ? MRMediaRemoteCommandPause : MRMediaRemoteCommandPlay;
    MRMediaRemoteSendCommand(command, nil);
}

- (void)skipTrack {
    MRMediaRemoteSendCommand(MRMediaRemoteCommandNextTrack, nil);
}

- (void)likeTrack {
    if (!self.supportsLiking) {
        // Not able to like
        return;
    }

    MRMediaRemoteSendCommand(MRMediaRemoteCommandLikeTrack, nil);
}

- (void)dislikeTrack {
    if (!self.supportsLiking) {
        // Not able to like
        return;
    }

    MRMediaRemoteSendCommand(MRMediaRemoteCommandDislikeTrack, nil);
}

@end