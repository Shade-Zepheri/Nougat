#import <UIKit/UIKit.h>

@interface NUAStatusBar : UIView {
    NSBundle *_imageBundle;
}
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) UILabel *dateLabel;
- (void)updateTextColor;
@end
