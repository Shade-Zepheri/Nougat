#import <SpringBoard/SBControlCenterController.h>

@interface SBControlCenterController (Private)
@property (getter=isVisible, readonly, nonatomic) BOOL visible;
@property (readonly, nonatomic) BOOL allowGestureForContentBelow;
@property (strong, nonatomic) UIPanGestureRecognizer *statusBarPullGestureRecognizer;

@end