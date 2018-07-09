#import <UIKit/UIKit.h>

@interface NUANotificationShadePanelView : UIView {
    NSLayoutConstraint *_topMargin;
    NSLayoutConstraint *_bottomMargin;
    NSLayoutConstraint *_leadingMargin;
    NSLayoutConstraint *_trailingMargin;
}

@property (strong, nonatomic) UIView *contentView;

+ (CGFloat)baseHeight;

- (instancetype)initWithDefaultSize;

- (void)expandHeight:(CGFloat)height;

@end