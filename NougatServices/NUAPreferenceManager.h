#import <UIKit/UIKit.h>
#import "NUAToggleInfo.h"

typedef NS_ENUM(NSUInteger, NUADrawerTheme) {
    NUADrawerThemeNexus,
    NUADrawerThemePixel,
    NUADrawerThemeOreo
};

// Settings keys
static NSString *const NUAPreferencesEnabledKey = @"enabled";

static NSString *const NUAPreferencesTogglesListKey = @"togglesList";

static NSString *const NUAPreferencesCurrentThemeKey = @"darkVariant";

static NSString *const NUAPreferencesUsesExternalColorKey = @"colorflowEnabled";
static NSString *const NUAPreferencesUsesSystemAppearanceKey = @"usesSystemAppearance";

@interface NUAPreferenceManager : NSObject
@property (class, strong, readonly) NUAPreferenceManager *sharedSettings;

@property (getter=isEnabled, readonly, nonatomic) BOOL enabled;

@property (strong, readonly, nonatomic) UIColor *backgroundColor;
@property (strong, readonly, nonatomic) UIColor *highlightColor;
@property (strong, readonly, nonatomic) UIColor *textColor;
@property (getter=isUsingDark, readonly, nonatomic) BOOL usingDark;

@property (copy, readonly, nonatomic) NSArray<NSString *> *enabledToggles;
@property (copy, readonly, nonatomic) NSArray<NSString *> *disabledToggles;

@property (readonly, nonatomic) BOOL useExternalColor;

+ (BOOL)_deviceHasNotch;
+ (NSString *)carrierName;

- (NSArray<NSString *> *)_installedToggleIdentifiers;
- (NUAToggleInfo *)toggleInfoForIdentifier:(NSString *)identifier;
- (void)refreshToggleInfo;

@end
