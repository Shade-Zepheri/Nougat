#import <Preferences/PSTableCell.h>
#import <AVFoundation/AVFoundation.h>

@interface NUAVideoTableCell : PSTableCell
@property (strong, readonly, nonatomic) AVPlayer *player;
@property (strong, readonly, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, readonly, nonatomic) AVPlayerItem *playerItem;
@property (getter=isPaused, nonatomic) BOOL paused;

@end