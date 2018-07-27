#import <Flipswitch/Flipswitch.h>
#import <UIKit/UIKit.h>

@interface NUAFlipswitchToggle : UIView

@property (strong, readonly, nonatomic) UIImageView *imageView;
@property (copy, nonatomic) NSString *switchIdentifier;
@property (strong, readonly, nonatomic) NSBundle *resourceBundle;
@property (readonly, nonatomic) FSSwitchState state;
@property (strong, readonly, nonatomic) UILabel *displayName;

+ (NSBundle *)sharedResourceBundle;

- (instancetype)initWithFrame:(CGRect)frame andSwitchIdentifier:(NSString *)identifier;

@end