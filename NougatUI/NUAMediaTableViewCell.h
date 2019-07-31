#import <UIKit/UIKit.h>
#import <MediaPlayerUI/MediaPlayerUI.h>
#import <MediaPlayerUI/MPUNowPlayingMetadata.h>

@interface NUAMediaTableViewCell : UITableViewCell <MPUNowPlayingDelegate>
@property (getter=isExpanded, readonly, nonatomic) BOOL expanded;

@property (getter=isPlaying, readonly, nonatomic) BOOL playing;
@property (strong, nonatomic) UIImage *nowPlayingArtwork;

@property (copy, nonatomic) NSString *nowPlayingAppDisplayID;
@property (strong, nonatomic) MPUNowPlayingMetadata *metadata;
@property (strong, readonly, nonatomic) MPUNowPlayingController *nowPlayingController;

@end