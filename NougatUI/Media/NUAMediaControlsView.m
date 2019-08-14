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
        [self.stackView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    }

    return self;
}

- (void)createArrangedViews{
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
}

- (void)setPlaying:(BOOL)playing {
    _playing = playing;

    // Update views
    [self _updatePlayPauseImage:YES];
}

- (void)setTintColor:(UIColor *)color {
    _tintColor = color;

    // Colorize images
    UIImage *skipButtonImage = [[UIImage imageNamed:@"Skip" inBundle:[NSBundle bundleForClass:[self class]]] _flatImageWithColor:color];
    [self.skipButton setImage:skipButtonImage forState:UIControlStateNormal];
    UIImage *rewindButtonImage = [[UIImage imageNamed:@"Rewind" inBundle:[NSBundle bundleForClass:[self class]]] _flatImageWithColor:color];
    [self.rewindButton setImage:rewindButtonImage forState:UIControlStateNormal];
    [self _updatePlayPauseImage:NO];
    UIImage *likeButtonImage = [[UIImage imageNamed:@"Like" inBundle:[NSBundle bundleForClass:[self class]]] _flatImageWithColor:color];
    [self.likeButton setImage:likeButtonImage forState:UIControlStateNormal];
    UIImage *dislikeButtonImage = [[UIImage imageNamed:@"Dislike" inBundle:[NSBundle bundleForClass:[self class]]] _flatImageWithColor:color];
    [self.dislikeButton setImage:dislikeButtonImage forState:UIControlStateNormal];

    // Color play
    [self _updatePlayPauseImage:NO];
}

- (void)_updatePlayPauseImage:(BOOL)animated {
    UIImage *currentImage = self.playButton.currentImage;
    NSString *imageName = self.playing ? @"Pause" : @"Play";
    UIImage *newImage = [[UIImage imageNamed:imageName inBundle:[NSBundle bundleForClass:[self class]]] _flatImageWithColor:self.tintColor];

    if (animated) { 
        CABasicAnimation *crossFade = [CABasicAnimation animationWithKeyPath:@"contents"];
        crossFade.duration = 0.3;
        crossFade.fromValue = (id)currentImage.CGImage;
        crossFade.toValue = (id)newImage.CGImage;
        crossFade.removedOnCompletion = NO;
        crossFade.fillMode = kCAFillModeForwards;
        [self.playButton.imageView.layer addAnimation:crossFade forKey:@"animateContents"];
    }

    //Make sure to add Image normally after so when the animation
    //is done it is set to the new Image
    [self.playButton setImage:newImage forState:UIControlStateNormal];
}

#pragma mark - Actions

- (void)rewindTrack {
    MRMediaRemoteSendCommand(MRMediaRemoteCommandPreviousTrack, nil);
}

- (void)playPauseTrack {
    BOOL currentlyPlaying = self.playing;
    MRMediaRemoteCommand command = currentlyPlaying ? MRMediaRemoteCommandPause : MRMediaRemoteCommandPlay;
    MRMediaRemoteSendCommand(command, nil);
    self.playing = !currentlyPlaying;   
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