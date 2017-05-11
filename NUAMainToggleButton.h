#import <UIKit/UIKit.h>

//TODO: temporary until i can combine both toggle classes
@interface NUAMainToggleButton : UIView {
    NSBundle *_imageBundle;
}
@property (strong, nonatomic) UIImageView *imageView;
@property (copy, nonatomic) NSString *switchIdentifier;
- (instancetype)initWithFrame:(CGRect)frame andSwitchIdentifier:(NSString*)identifier;
@end
