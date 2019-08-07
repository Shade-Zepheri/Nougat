#import "NUATableViewCell.h"
#import <ColorFlow/ColorFlow.h>
#import <MediaPlayerUI/MediaPlayerUI.h>
#import <MediaPlayerUI/MPUNowPlayingMetadata.h>
#import <NougatServices/NougatServices.h>

@interface NUAMediaTableViewCell : NUATableViewCell <CFWColorDelegate, MPUNowPlayingDelegate>
@property (strong, readonly, nonatomic) NUAPreferenceManager *settings;
@property (getter=isPlaying, readonly, nonatomic) BOOL playing;
@property (strong, nonatomic) UIImage *nowPlayingArtwork;

@property (copy, nonatomic) NSString *nowPlayingAppDisplayID;
@property (strong, nonatomic) MPUNowPlayingMetadata *metadata;
@property (strong, readonly, nonatomic) MPUNowPlayingController *nowPlayingController;

@end