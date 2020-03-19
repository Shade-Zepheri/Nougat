#import <UIKit/UIKit.h>

@interface NUANotificationShadePanelView : UIView
@property (strong, nonatomic) UIView *contentView;
@property (assign, nonatomic) CGFloat inset;
@property (assign, nonatomic) CGFloat revealPercentage;
@property (assign, nonatomic) CGFloat fullyPresentedHeight;

@property (strong, nonatomic) NSLayoutConstraint *insetConstraint;

- (instancetype)initWithDefaultSize;

@end