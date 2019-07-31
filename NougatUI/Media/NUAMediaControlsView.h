#import <UIKit/UIKit.h>

@interface NUAMediaControlsView : UIView
@property (getter=isExpanded, nonatomic) BOOL expanded;

@property (getter=isPlaying, nonatomic) BOOL playing;
@property (strong, nonatomic) UIColor *tintColor;

@end