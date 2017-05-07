#import <UIKit/UIKit.h>

@interface NUADrawerPanelButton : UIView {
  BOOL _toggled;
}
@property (strong, nonatomic) UIImage *toggleImage;
@property (copy, nonatomic) NSString *switchIdentifier;
- (instancetype)initWithFrame:(CGRect)frame andSwitchIdentifier:(NSString*)identifier;
@end
