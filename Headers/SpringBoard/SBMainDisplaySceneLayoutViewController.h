#import "SBSceneLayoutViewController.h"

@interface SBMainDisplaySceneLayoutViewController : SBSceneLayoutViewController

- (void)_requireUnpinPanSystemGestureRecognizerFailureForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer; // iOS 11-12

- (UIGestureRecognizer *)sideSwitcherRevealGesture; // iOS 10

@end