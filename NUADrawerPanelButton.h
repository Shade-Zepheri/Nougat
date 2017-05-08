#import <UIKit/UIKit.h>

@interface NUADrawerPanelButton : UIView {
    NSBundle *_imageBundle;
}
@property (strong, nonatomic) UIImageView *imageView;
@property (copy, nonatomic) NSString *switchIdentifier;
- (instancetype)initWithFrame:(CGRect)frame andSwitchIdentifier:(NSString*)identifier;
@end
