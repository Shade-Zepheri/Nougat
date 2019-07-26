#import <UIKit/UIKit.h>

@interface NUAMediaControlsView : UIView
@property (getter=isPlaying, nonatomic) BOOL playing;
@property (strong, nonatomic) UIColor *tintColor;

@property (getter=isSongLiked, nonatomic) BOOL songLiked;

@end