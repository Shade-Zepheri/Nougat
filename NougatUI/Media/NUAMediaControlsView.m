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
    UIImage *likeButtonImage = [[UIImage imageNamed:@"Like" inBundle:[NSBundle bundleForClass:[self class]]] _flatImageWithColor:[UIColor whiteColor]];
    [self.likeButton setImage:likeButtonImage forState:UIControlStateNormal];
    self.likeButton.hidden = YES;

    self.rewindButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rewindButton addTarget:self action:@selector(rewindTrack) forControlEvents:UIControlEventTouchUpInside];
    UIImage *rewindButtonImage = [[UIImage imageNamed:@"Rewind" inBundle:[NSBundle bundleForClass:[self class]]] _flatImageWithColor:[UIColor whiteColor]];
    [self.rewindButton setImage:rewindButtonImage forState:UIControlStateNormal];

    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playButton addTarget:self action:@selector(playPauseTrack) forControlEvents:UIControlEventTouchUpInside];
    UIImage *playButtonImage = [[UIImage imageNamed:@"Play" inBundle:[NSBundle bundleForClass:[self class]]] _flatImageWithColor:[UIColor whiteColor]];
    [self.playButton setImage:playButtonImage forState:UIControlStateNormal];

    self.skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.skipButton addTarget:self action:@selector(skipTrack) forControlEvents:UIControlEventTouchUpInside];
    UIImage *skipButtonImage = [[UIImage imageNamed:@"Skip" inBundle:[NSBundle bundleForClass:[self class]]] _flatImageWithColor:[UIColor whiteColor]];
    [self.skipButton setImage:skipButtonImage forState:UIControlStateNormal];

    self.dislikeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.dislikeButton addTarget:self action:@selector(dislikeTrack) forControlEvents:UIControlEventTouchUpInside];
    UIImage *dislikeButtonImage = [[UIImage imageNamed:@"Dislike" inBundle:[NSBundle bundleForClass:[self class]]] _flatImageWithColor:[UIColor whiteColor]];
    [self.dislikeButton setImage:dislikeButtonImage forState:UIControlStateNormal];
    self.dislikeButton.hidden = YES;
}

#pragma mark - Properties

- (void)setExpanded:(BOOL)expanded {
    _expanded = expanded;

    // Show buttons
    self.likeButton.hidden = !expanded;
    self.dislikeButton.hidden = !expanded;
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

- (void)setTintColor:(UIColor *)color {
    _tintColor = color;

    // Colorize images
    UIImage *skipButtonImage = [[UIImage imageNamed:@"Skip" inBundle:[NSBundle bundleForClass:self.class]] _flatImageWithColor:color];
    [self.skipButton setImage:skipButtonImage forState:UIControlStateNormal];

    UIImage *rewindButtonImage = [[UIImage imageNamed:@"Rewind" inBundle:[NSBundle bundleForClass:self.class]] _flatImageWithColor:color];
    [self.rewindButton setImage:rewindButtonImage forState:UIControlStateNormal];

    UIImage *likeButtonImage = [[UIImage imageNamed:@"Like" inBundle:[NSBundle bundleForClass:self.class]] _flatImageWithColor:color];
    [self.likeButton setImage:likeButtonImage forState:UIControlStateNormal];

    UIImage *dislikeButtonImage = [[UIImage imageNamed:@"Dislike" inBundle:[NSBundle bundleForClass:self.class]] _flatImageWithColor:color];
    [self.dislikeButton setImage:dislikeButtonImage forState:UIControlStateNormal];

    // Color play
    [self _updatePlayPauseImage:NO];
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
    BOOL currentlyPlaying = self.playing;
    MRMediaRemoteCommand command = currentlyPlaying ? MRMediaRemoteCommandPause : MRMediaRemoteCommandPlay;
    MRMediaRemoteSendCommand(command, nil);
}

- (void)skipTrack {
    MRMediaRemoteSendCommand(MRMediaRemoteCommandNextTrack, nil);
}

- (void)likeTrack {
    MRMediaRemoteSendCommand(MRMediaRemoteCommandLikeTrack, nil);
}

- (void)dislikeTrack {
    MRMediaRemoteSendCommand(MRMediaRemoteCommandDislikeTrack, nil);
}

@end