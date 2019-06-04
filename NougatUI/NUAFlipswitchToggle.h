#import "NUARippleButton.h"
#import <Flipswitch/Flipswitch.h>

@interface NUAFlipswitchToggle : NUARippleButton
@property (strong, readonly, nonatomic) UIImageView *imageView;
@property (copy, nonatomic) NSString *switchIdentifier;
@property (strong, readonly, nonatomic) NSBundle *resourceBundle;
@property (readonly, nonatomic) FSSwitchState switchState;
@property (strong, readonly, nonatomic) UILabel *displayName;

+ (NSBundle *)sharedResourceBundle;

- (instancetype)initWithFrame:(CGRect)frame andSwitchIdentifier:(NSString *)identifier;

@end