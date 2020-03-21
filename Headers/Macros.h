#import <HBLog.h>
#import <theos/IOSMacros.h>

#define kScreenWidth CGRectGetMaxX([UIScreen mainScreen].bounds)
#define kScreenHeight CGRectGetMaxY([UIScreen mainScreen].bounds)

#define NUALogCurrentMethod HBLogDebug(@"[Nougat] Method called: %@", NSStringFromSelector(_cmd))

#define NexusBackgroundColor [UIColor colorWithRed:0.15 green:0.20 blue:0.22 alpha:1.0]
#define NexusTintColor [UIColor colorWithRed:0.39 green:1.00 blue:0.85 alpha:1.0]

#define PixelBackgroundColor [UIColor colorWithRed:0.13 green:0.13 blue:0.13 alpha:1.0]
#define PixelTintColor [UIColor colorWithRed:0.27 green:0.54 blue:1.00 alpha:1.0]

#define OreoBackgroundColor [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0]
#define OreoTintColor PixelTintColor
#define OreoDividerColor [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0]
