#import <UIKit/UIKit.h>

@class SBCoverSheetSystemGesturesDelegate, SBScreenEdgePanGestureRecognizer;

@interface SBCoverSheetSlidingViewController : UIViewController
@property (strong, nonatomic) SBScreenEdgePanGestureRecognizer *dismissGestureRecognizer;
@property (strong, nonatomic) SBScreenEdgePanGestureRecognizer *dismissAddendumGestureRecognizer;
@property (strong, nonatomic) UIGestureRecognizer *indirectPresentGestureRecognizer;
@property (strong, nonatomic) UIGestureRecognizer *indirectDismissGestureRecognizer;
@property (strong, nonatomic) SBCoverSheetSystemGesturesDelegate *systemGesturesDelegate;

@end