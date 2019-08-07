// ColorFlow 4 Public SpringBoard API Headers.

@class MPModelSong;

@interface CFWColorInfo : NSObject
@property(nonatomic, retain) UIColor *backgroundColor;
@property(nonatomic, retain) UIColor *primaryColor;
@property(nonatomic, retain) UIColor *secondaryColor;
@property(nonatomic, assign, getter=isBackgroundDark) BOOL backgroundDark;
@end

// Your class should implement these methods for use as a CFWSBMediaController color delegate.
// You may assume that these methods are called on the main thread.
@protocol CFWColorDelegate<NSObject>
// Called when color analysis is complete for the current song. This will only be called from the
// main thread.
- (void)songAnalysisComplete:(MPModelSong *)song
                     artwork:(UIImage *)artwork
                   colorInfo:(CFWColorInfo *)colorInfo;

// Called if the current song doesn't have artwork. Note that ColorFlow might wait a few seconds for
// the artwork to load before this is called. This will only be called from the main thread.
- (void)songHadNoArtwork:(MPModelSong *)song;
@end

@interface CFWSBMediaController : NSObject
+ (instancetype)sharedInstance;

// Adds a delegate, but if a song is already playing, don't notify the delegate of it.
- (void)addColorDelegate:(id<CFWColorDelegate>)delegate;

// Adds a delegate and notify it if a song is already playing. Note that ColorFlow 4 analysis is
// deferred (lazy), so either:
//   1. The analysis is already complete and this method will immediately notify your delegate.
//   2. The analysis isn't already complete - this method will not immediately notify your delegate.
//      The delegate will be notified asynchronously when analysis is complete (on the main thread).
- (void)addColorDelegateAndNotify:(id<CFWColorDelegate>)delegate;

// Remove your delegate whenever you don't want analysis to occur - i.e. if your view is hidden.
- (void)removeColorDelegate:(id<CFWColorDelegate>)delegate;
@end