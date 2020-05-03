#import <SpringBoard/SBControlCenterController.h>

@interface SBControlCenterController (Private)
@property (getter=isVisible, readonly, nonatomic) BOOL visible;
@property (strong, nonatomic) UIPanGestureRecognizer *statusBarPullGestureRecognizer;

@end