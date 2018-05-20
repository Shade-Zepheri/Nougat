#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, NUADrawerTheme) {
    NUADrawerThemeNexus,
    NUADrawerThemePixel,
    NUADrawerThemeOreo
};

// Settings keys
static NSString *const NUAPreferencesEnabledKey = @"enabled";

static NSString *const NUAPreferencesTogglesListKey = @"togglesList";

static NSString *const NUAPreferencesCurrentThemeKey = @"darkVariant";

@interface NUAPreferenceManager : NSObject

@property (assign, readonly, nonatomic) BOOL enabled;
@property (strong, readonly, nonatomic) UIColor *backgroundColor;
@property (strong, readonly, nonatomic) UIColor *highlightColor;
@property (copy, readonly, nonatomic) NSArray <NSString *> *togglesList;

+ (instancetype)sharedSettings;

+ (NSString *)currentWifiSSID;
+ (NSString *)carrierName;

@end
