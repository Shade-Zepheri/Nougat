#import <UIKit/UIKit.h>

#import "NUADynamicRippleView.h"

@interface NUARippleButton : UIButton
@property (assign, nonatomic) NUARippleStyle rippleStyle;
@property (strong, nonatomic) UIColor *rippleColor;

@property (nonatomic) UIEdgeInsets touchAreaInsets;

#pragma mark - Disables

// UIButton subclasses cant use this method
+ (instancetype)buttonWithType:(UIButtonType)buttonType NS_UNAVAILABLE;

@end