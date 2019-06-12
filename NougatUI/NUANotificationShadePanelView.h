#import <UIKit/UIKit.h>

@interface NUANotificationShadePanelView : UIView
@property (strong, nonatomic) UIView *contentView;
@property (assign, nonatomic) CGFloat height;
@property (strong, nonatomic) NSLayoutConstraint *heightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *insetConstraint;

- (instancetype)initWithDefaultSize;

@end