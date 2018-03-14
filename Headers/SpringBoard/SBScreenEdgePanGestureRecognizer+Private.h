#import <SpringBoard/SBScreenEdgePanGestureRecognizer.h>
#import "SBSystemGestureRecognizerDelegate.h"
#import "UIGestureRecognizer+SpringBoard.h"

@interface SBScreenEdgePanGestureRecognizer (Extras)

@property (nonatomic, weak) id<SBSystemGestureRecognizerDelegate> delegate;

@end
