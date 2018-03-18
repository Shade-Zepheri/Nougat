#import <SpringBoard/SBScreenEdgePanGestureRecognizer.h>
#import <UIKit/UIScreenEdgePanGestureRecognizer+Private.h>
#import "SBSystemGestureRecognizerDelegate.h"
#import "UIGestureRecognizer+SpringBoard.h"

@interface SBScreenEdgePanGestureRecognizer (Extras)

@property (weak, nonatomic) id<SBSystemGestureRecognizerDelegate> delegate;

@end
