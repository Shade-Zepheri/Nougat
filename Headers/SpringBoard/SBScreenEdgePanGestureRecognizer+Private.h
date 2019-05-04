#import <SpringBoard/SBScreenEdgePanGestureRecognizer.h>
#import <SpringBoard/SBSystemGestureRecognizerDelegate.h>
#import <SpringBoard/UIGestureRecognizer+SpringBoard.h>
#import <UIKit/UIScreenEdgePanGestureRecognizer+Private.h>

@interface SBScreenEdgePanGestureRecognizer (Extras)

@property (weak, nonatomic) id<SBSystemGestureRecognizerDelegate> delegate;

@end
