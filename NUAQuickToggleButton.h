#import <UIKit/UIKit.h>

@interface NUAQuickToggleButton : UIView

@property (strong, readonly, nonatomic) UIImageView *imageView;
@property (copy, readonly, nonatomic) NSString *switchIdentifier;
@property (strong, readonly, nonatomic) NSBundle *resourceBundle;

+ (CGSize)imageSize;

- (instancetype)initWithFrame:(CGRect)frame andSwitchIdentifier:(NSString *)identifier;

- (void)switchesChangedState:(NSNotification *)notification;

@end
