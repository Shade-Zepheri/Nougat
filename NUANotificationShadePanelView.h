#import <UIKit/UIKit.h>

@interface NUANotificationShadePanelView : UIView
@property (strong, nonatomic) UIView *contentView;

+ (CGFloat)baseHeight;

- (instancetype)initWithDefaultSize;

- (void)expandHeight:(CGFloat)height;

@end