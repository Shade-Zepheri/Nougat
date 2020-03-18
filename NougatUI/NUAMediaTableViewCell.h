#import "NUATableViewCell.h"
#import <ColorFlow/ColorFlow.h>
#import <MediaPlayerUI/MediaPlayerUI.h>
#import <MediaPlayerUI/MPUNowPlayingMetadata.h>
#import <NougatServices/NougatServices.h>

@interface NUAMediaTableViewCell : NUATableViewCell <MPUNowPlayingDelegate>
@property (getter=isPlaying, readonly, nonatomic) BOOL playing;

@property (strong, nonatomic) MPUNowPlayingMetadata *metadata;
@property (strong, nonatomic) UIImage *nowPlayingArtwork;
@property (copy, nonatomic) NSString *nowPlayingAppDisplayID;

- (void)registerForMediaNotifications;
- (void)unregisterForMediaNotifications;

@end