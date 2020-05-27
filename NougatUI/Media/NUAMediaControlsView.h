#import <UIKit/UIKit.h>

@interface NUAMediaControlsView : UIView
@property (getter=isExpanded, nonatomic) BOOL expanded;
@property (getter=isPlaying, nonatomic) BOOL playing;
@property (getter=isLiked, nonatomic) BOOL supportsLiking;
@property (getter=isLiked, nonatomic) BOOL liked;
@property (getter=isDisliked, nonatomic) BOOL disliked;
@property (strong, nonatomic) UIColor *tintColor;

@end