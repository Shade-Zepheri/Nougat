#import <UIKit/UIKit.h>

//TODO: temporary until i can combine both toggle classes
@interface NUAMainToggleButton : UIView
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) NSBundle *resourceBundle;
@property (copy, nonatomic) NSString *switchIdentifier;
@property (strong, nonatomic) UILabel *toggleLabel;
- (instancetype)initWithFrame:(CGRect)frame andSwitchIdentifier:(NSString*)identifier;
@end
