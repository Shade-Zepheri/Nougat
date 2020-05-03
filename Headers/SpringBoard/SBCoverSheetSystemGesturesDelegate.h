#import <UIKit/UIKit.h>

@interface SBCoverSheetSystemGesturesDelegate : NSObject
@property (strong, nonatomic) UIPanGestureRecognizer *presentGestureRecognizer;

// Convenience methods added by me
- (CGPoint)nua_locationOfTouchInActiveInterfaceOrientation:(UIGestureRecognizer *)gestureRecognizer;
- (BOOL)nua_isLocationXWithinLeadingStatusBarRegion:(CGPoint)location;

@end