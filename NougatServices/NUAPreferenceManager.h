#import <UIKit/UIKit.h>
#import "NUAToggleInfo.h"

typedef NS_ENUM(NSInteger, NUADrawerTheme) {
    NUADrawerThemeNexus,
    NUADrawerThemePixel,
    NUADrawerThemeOreo
};

typedef NS_ENUM(NSInteger, NUANotificationPreviewSetting) {
    NUANotificationPreviewSettingAlways,
    NUANotificationPreviewSettingWhenUnlocked,
    NUANotificationPreviewSettingNever
};

// Settings keys
static NSString *const NUAPreferencesEnabledKey = @"enabled";

static NSString *const NUAPreferencesFirstTimeUserKey = @"firstTimeUser";

static NSString *const NUAPreferencesTogglesListKey = @"togglesList";

static NSString *const NUAPreferencesCurrentThemeKey = @"darkVariant";

static NSString *const NUAPreferencesUsesExternalColorKey = @"colorflowEnabled";
static NSString *const NUAPreferencesUsesSystemAppearanceKey = @"usesSystemAppearance";
static NSString *const NUAPreferencesNotificationPreviewSettingKey = @"notificationPreviewSetting";
static NSString *const NUAPreferencesHideStatusBarModuleKey = @"hideStatusBar";
static NSString *const NUAPreferencesDisableGesturesKey = @"disableGestures";

@interface NUAPreferenceManager : NSObject
@property (class, strong, readonly) NUAPreferenceManager *sharedSettings;

@property (getter=isEnabled, readonly, nonatomic) BOOL enabled;

@property (getter=isFirstTimeUser, readonly, nonatomic) BOOL firstTimeUser;

@property (strong, readonly, nonatomic) UIColor *backgroundColor;
@property (strong, readonly, nonatomic) UIColor *highlightColor;
@property (strong, readonly, nonatomic) UIColor *textColor;
@property (getter=isUsingDark, readonly, nonatomic) BOOL usingDark;

@property (copy, readonly, nonatomic) NSSet<NSString *> *loadableToggleIdentifiers;
@property (copy, readonly, nonatomic) NSArray<NSString *> *enabledToggleIdentifiers;

@property (assign, readonly, nonatomic) BOOL useExternalColor;
@property (assign, readonly, nonatomic) BOOL usesSystemAppearance;
@property (assign, readonly, nonatomic) NUANotificationPreviewSetting notificationPreviewSetting;

@property (assign, readonly, nonatomic) BOOL hideStatusBarModule;
@property (assign, readonly, nonatomic) BOOL disableGestures;

+ (BOOL)_deviceHasNotch;
+ (NSString *)carrierName;

- (NUAToggleInfo *)toggleInfoForIdentifier:(NSString *)identifier;

- (void)setHasBeenPrompted;

@end
