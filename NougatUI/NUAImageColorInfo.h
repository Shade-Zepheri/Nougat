#import <UIKit/UIKit.h>
#import <Palette/Palette.h>

@interface NUAImageColorInfo : NSObject
@property (strong, readonly, nonatomic) UIColor *primaryColor;
@property (strong, readonly, nonatomic) UIColor *secondaryColor;
@property (strong, readonly, nonatomic) UIColor *accentColor;
@property (strong, readonly, nonatomic) UIColor *textColor;

+ (instancetype)colorInfoFromPalette:(UIImageColorPalette *)palette;

@end