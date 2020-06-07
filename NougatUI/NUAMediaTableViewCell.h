#import "NUATableViewCellBase.h"
#import <ColorFlow/ColorFlow.h>
#import <MediaPlayerUI/MediaPlayerUI.h>
#import <MediaPlayerUI/MPUNowPlayingMetadata.h>
#import <NougatServices/NougatServices.h>

@interface NUAMediaTableViewCell : NUATableViewCellBase <MPUNowPlayingDelegate>
@property (getter=isPlaying, readonly, nonatomic) BOOL playing;

@property (strong, nonatomic) MPUNowPlayingController *nowPlayingController;
@property (strong, nonatomic) NUAPreferenceManager *notificationShadePreferences;
@property (strong, nonatomic) MPUNowPlayingMetadata *metadata;
@property (strong, nonatomic) UIImage *nowPlayingArtwork;
@property (copy, nonatomic) NSString *nowPlayingAppDisplayID;

@end