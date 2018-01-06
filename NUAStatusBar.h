#import <UIKit/UIKit.h>

@interface NUAStatusBar : UIView
@property (strong, readonly, nonatomic) NSBundle *resourceBundle;
@property (strong, readonly, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, readonly, nonatomic) UILabel *dateLabel;
@property (strong, readonly, nonatomic) UIButton *toggleButton;

- (void)updateToggle:(BOOL)toggled;

@end
