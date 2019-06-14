#import "NUAVideoTableCell.h"
#import <Preferences/PSSpecifier.h>

@implementation NUAVideoTableCell

#pragma mark - Init

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];
	if (self) {
        // Hide everything
		self.imageView.hidden = YES;
		self.textLabel.hidden = YES;
		self.detailTextLabel.hidden = YES;

        // Get video url
        NSString *videoName = specifier.identifier;
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSURL *videoURL = [bundle URLForResource:videoName withExtension:@"mov"];

		// Create player
        _playerItem = [AVPlayerItem playerItemWithURL:videoURL];
        _player = [AVPlayer playerWithPlayerItem:self.playerItem];
        self.player.volume = 0.0;
        self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        self.playerLayer.frame = self.bounds;
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        [self.layer insertSublayer:self.playerLayer atIndex:0];

        [self.player play];

        // Add tap to pause
         UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [self addGestureRecognizer:tapGesture];

        // Register for notification for loop
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
	}

	return self;
}

- (instancetype)initWithSpecifier:(PSSpecifier *)specifier {
	self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil specifier:specifier];
	return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.playerLayer.frame = self.bounds;
}

#pragma mark - Properties

- (void)setPaused:(BOOL)paused {
    _paused = paused;

    // Update playback according;
    if (paused) {
        [self.player pause];
    } else {
        [self.player play];
    }
}

#pragma mark - Gesture

- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer {
    self.paused = !self.paused;
}

#pragma mark - Notification

- (void)playerDidReachEnd:(NSNotification *)notification {
    // Loop to beginning
    [self.playerItem seekToTime:kCMTimeZero];
}

@end