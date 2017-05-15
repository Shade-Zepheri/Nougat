#import <UIKit/UIKit.h>

@interface NUAStatusBar : UIView
@property (strong, nonatomic) NSBundle *resourceBundle;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UIButton *toggleButton;
- (void)updateToggle:(BOOL)toggled;
@end
