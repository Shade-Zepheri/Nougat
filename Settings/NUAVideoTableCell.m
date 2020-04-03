#import "NUAVideoTableCell.h"
#import <Preferences/PSSpecifier.h>

@implementation NUAVideoTableCell

#pragma mark - Initialization

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];
	if (self) {
        // Hide everything
		self.imageView.hidden = YES;
		self.textLabel.hidden = YES;
		self.detailTextLabel.hidden = YES;

        // Get video url
        NSString *videoURLString = [NSString stringWithFormat:@"https://shade-zepheri.github.io/depic/com.shade.nougat/videos/%@.mov", specifier.identifier];
        NSURL *videoURL = [NSURL URLWithString:videoURLString];

		// Create player
        _playerItem = [AVPlayerItem playerItemWithURL:videoURL];
        _player = [AVPlayer playerWithPlayerItem:self.playerItem];
        self.player.volume = 0.0;
        self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        [self.player addObserver:self forKeyPath:@"status" options:0 context:nil];

        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.frame = self.bounds;
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        [self.layer insertSublayer:self.playerLayer atIndex:0];

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

- (void)dealloc {
    // Unregister KVO
    [self.player removeObserver:self forKeyPath:@"status" context:nil];
}

#pragma mark - View Management

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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {
    if (object != self.player || ![keyPath isEqualToString:@"status"]) {
        // return of not applicable
        return;
    }

    switch (self.player.status) {
        case AVPlayerStatusUnknown:
            break;
        case AVPlayerStatusFailed: { 
            // Show error
            NSError *error = self.player.error;

            self.textLabel.hidden = NO;
            self.textLabel.text = error.localizedDescription;
            break;
        }
        case AVPlayerStatusReadyToPlay:
            // Start playing
            self.paused = NO;
            self.textLabel.hidden = YES;
            break;
    }
}

@end