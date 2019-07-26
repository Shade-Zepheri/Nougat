#import "NUAMediaControlsView.h"
#import <MediaRemote/MediaRemote.h>
#import <UIKit/UIImage+Private.h>

@interface NUAMediaControlsView ()
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
        // Constraint up
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self.widthAnchor constraintEqualToConstant:260.0].active = YES;
        [self.heightAnchor constraintEqualToConstant:50].active = YES;

        // Controls
        self.likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.likeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.likeButton addTarget:self action:@selector(likeTrack) forControlEvents:UIControlEventTouchUpInside];
        UIImage *likeButtonImage = [[UIImage imageNamed:@"Like" inBundle:[NSBundle bundleForClass:[self class]]] _flatImageWithColor:[UIColor whiteColor]];
        [self.likeButton setImage:likeButtonImage forState:UIControlStateNormal];
        [self addSubview:self.likeButton];

        [self.likeButton.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
        [self.likeButton.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
        [self.likeButton.widthAnchor constraintEqualToConstant:48.0].active = YES;
        [self.likeButton.heightAnchor constraintEqualToConstant:48.0].active = YES;

        self.rewindButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.rewindButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.rewindButton addTarget:self action:@selector(rewindTrack) forControlEvents:UIControlEventTouchUpInside];
        UIImage *rewindButtonImage = [[UIImage imageNamed:@"Rewind" inBundle:[NSBundle bundleForClass:[self class]]] _flatImageWithColor:[UIColor whiteColor]];
        [self.rewindButton setImage:rewindButtonImage forState:UIControlStateNormal];
        [self addSubview:self.rewindButton];

        [self.rewindButton.leadingAnchor constraintEqualToAnchor:self.likeButton.trailingAnchor constant:5.0].active = YES;
        [self.rewindButton.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
        [self.rewindButton.widthAnchor constraintEqualToConstant:48.0].active = YES;
        [self.rewindButton.heightAnchor constraintEqualToConstant:48.0].active = YES;   

        self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.playButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.playButton addTarget:self action:@selector(playPauseTrack) forControlEvents:UIControlEventTouchUpInside];
        UIImage *playButtonImage = [[UIImage imageNamed:@"Play" inBundle:[NSBundle bundleForClass:[self class]]] _flatImageWithColor:[UIColor whiteColor]];
        [self.playButton setImage:playButtonImage forState:UIControlStateNormal];
        [self addSubview:self.playButton];

        [self.playButton.leadingAnchor constraintEqualToAnchor:self.rewindButton.trailingAnchor constant:5.0].active = YES;
        [self.playButton.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
        [self.playButton.widthAnchor constraintEqualToConstant:48.0].active = YES;
        [self.playButton.heightAnchor constraintEqualToConstant:48.0].active = YES;

        self.skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.skipButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.skipButton addTarget:self action:@selector(skipTrack) forControlEvents:UIControlEventTouchUpInside];
        UIImage *skipButtonImage = [[UIImage imageNamed:@"Skip" inBundle:[NSBundle bundleForClass:[self class]]] _flatImageWithColor:[UIColor whiteColor]];
        [self.skipButton setImage:skipButtonImage forState:UIControlStateNormal];
        [self addSubview:self.skipButton];

        [self.skipButton.leadingAnchor constraintEqualToAnchor:self.playButton.trailingAnchor constant:5.0].active = YES;
        [self.skipButton.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
        [self.skipButton.widthAnchor constraintEqualToConstant:48.0].active = YES;
        [self.skipButton.heightAnchor constraintEqualToConstant:48.0].active = YES;

        self.dislikeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.dislikeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.dislikeButton addTarget:self action:@selector(dislikeTrack) forControlEvents:UIControlEventTouchUpInside];
        UIImage *dislikeButtonImage = [[UIImage imageNamed:@"Dislike" inBundle:[NSBundle bundleForClass:[self class]]] _flatImageWithColor:[UIColor whiteColor]];
        [self.dislikeButton setImage:dislikeButtonImage forState:UIControlStateNormal];
        [self addSubview:self.dislikeButton];

        [self.dislikeButton.leadingAnchor constraintEqualToAnchor:self.skipButton.trailingAnchor constant:5.0].active = YES;
        [self.dislikeButton.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
        [self.dislikeButton.widthAnchor constraintEqualToConstant:48.0].active = YES;
        [self.dislikeButton.heightAnchor constraintEqualToConstant:48.0].active = YES;  
    }

    return self;
}

#pragma mark - Properties

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