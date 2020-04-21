#import "NUAPreferenceManager.h"
#import <Macros.h>
#import <Cephei/HBPreferences.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import <UIKit/UIWindow+Private.h>

@interface NUAPreferenceManager () {
    HBPreferences *_preferences;

    NUADrawerTheme _currentTheme;
    NSMutableDictionary<NSString *, NUAToggleInfo *> *_toggleInfoDictionary;
}

@end

@implementation NUAPreferenceManager

+ (instancetype)sharedSettings {
    static NUAPreferenceManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _toggleInfoDictionary = [NSMutableDictionary dictionary];

        _preferences = [HBPreferences preferencesForIdentifier:@"com.shade.nougat"];

        [_preferences registerBool:&_enabled default:YES forKey:NUAPreferencesEnabledKey];
        [_preferences registerBool:&_firstTimeUser default:YES forKey:NUAPreferencesFirstTimeUserKey];
        [_preferences registerInteger:(NSInteger *)&_currentTheme default:NUADrawerThemeNexus forKey:NUAPreferencesCurrentThemeKey];
        [_preferences registerBool:&_useExternalColor default:NO forKey:NUAPreferencesUsesExternalColorKey];
        [_preferences registerBool:&_usesSystemAppearance default:NO forKey:NUAPreferencesUsesSystemAppearanceKey];

        NSArray<NSString *> *defaultToggleOrder = [self.class _defaultEnabledToggles];
        [_preferences registerObject:&_enabledToggles default:defaultToggleOrder forKey:NUAPreferencesTogglesListKey];

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(preferencesWereUpdated) name:HBPreferencesDidChangeNotification object:_preferences];
        [self preferencesWereUpdated];

        // Migrate if needed
        if ([self _hasLegacyPrefs]) {
            [self _migrateFromLegacyPrefs];
        }

        // Now check for my broken migration
        if ([self _hasBrokenMigration]) {
            [self _fixBrokenMigration];
        }

        // Get toggle info
        [self refreshToggleInfo];
    }

    return self;
}

#pragma mark - Properties

- (UIColor *)backgroundColor {
    if (self.usesSystemAppearance) {
        // Derive from system appearance
        if (@available(iOS 13, *)) {
            // To silence warnings
            UITraitCollection *traitCollection = UITraitCollection.currentTraitCollection;
            BOOL usingDarkAppearance = traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
            return usingDarkAppearance ? PixelBackgroundColor : OreoBackgroundColor;
        }
    } 

    // Derive manually
    switch (_currentTheme) {
        case NUADrawerThemeNexus:
            return NexusBackgroundColor;
        case NUADrawerThemePixel:
            return PixelBackgroundColor;
        case NUADrawerThemeOreo:
            return OreoBackgroundColor;
    }
}

- (UIColor *)highlightColor {
    if (self.usesSystemAppearance) {
        // Derive from system appearance
        if (@available(iOS 13, *)) {
            // To silence warnings
            UITraitCollection *traitCollection = UITraitCollection.currentTraitCollection;
            BOOL usingDarkAppearance = traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
            return usingDarkAppearance ? PixelTintColor : OreoTintColor;
        }
    }

    // Derive manually
    switch (_currentTheme) {
        case NUADrawerThemeNexus:
            return NexusTintColor;
        case NUADrawerThemePixel:
            return PixelTintColor;
        case NUADrawerThemeOreo:
            return OreoTintColor;
    }
}

- (UIColor *)textColor {
    if (self.usesSystemAppearance) {
        // Derive from system appearance
        if (@available(iOS 13, *)) {
            // To silence warnings
            return UIColor.labelColor;
        }
    }
    
    // Derive manually
    return (_currentTheme == NUADrawerThemeOreo) ? [UIColor blackColor] : [UIColor whiteColor];
}

- (BOOL)isUsingDark {
    if (self.usesSystemAppearance) {
        // Derive from system appearance
        if (@available(iOS 13, *)) {
            // To silence warnings
            UITraitCollection *traitCollection = UITraitCollection.currentTraitCollection;
            return traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight;
        }
    }

    return _currentTheme == NUADrawerThemeOreo;
}

#pragma mark - Callbacks

- (void)preferencesWereUpdated {
    // Update toggle info
    [self refreshToggleInfo];

    // Publish general updates
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NUANotificationShadeChangedPreferences" object:nil userInfo:nil];

    // Publish appearance updates
    NSDictionary<NSString *, UIColor *> *colorInfo = @{@"backgroundColor": self.backgroundColor, @"tintColor": self.highlightColor, @"textColor": self.textColor};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NUANotificationShadeChangedBackgroundColor" object:nil userInfo:colorInfo];
}

#pragma mark - Toggles

- (void)refreshToggleInfo {
    NSError *error = nil;
    NSURL *togglesURL = [NSURL fileURLWithPath:@"/Library/Nougat/Toggles/"];
    NSArray<NSURL *> *bundleURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:togglesURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
    if (bundleURLs) {
        for (NSURL *bundleURL in bundleURLs) {
            NUAToggleInfo *info = [NUAToggleInfo toggleInfoWithBundleURL:bundleURL];
            if (info) {
                _toggleInfoDictionary[info.identifier] = info;
            }
        }
    } else {
        // Error, return
        HBLogError(@"%@", error);
        return;
    }

    // Construct disabled toggles
    NSMutableArray<NSString *> *disabledToggles = [NSMutableArray array];
    for (NSString *identifier in _toggleInfoDictionary.allKeys) {
        if ([self.enabledToggles containsObject:identifier]) {
            continue;
        }

        [disabledToggles addObject:identifier];
    }

    _disabledToggles = [disabledToggles copy];
}

- (NUAToggleInfo *)toggleInfoForIdentifier:(NSString *)identifier {
    return _toggleInfoDictionary[identifier];
}

- (NSArray<NSString *> *)_installedToggleIdentifiers {
    return _toggleInfoDictionary.allKeys;
}

#pragma mark - Migration

- (BOOL)_hasLegacyPrefs {
    // Check if toggles list has old keys
    return [self.enabledToggles containsObject:@"do-not-disturb"];
}

- (void)_migrateFromLegacyPrefs {
    // Change old keys into their new equivalent key
    NSArray<NSString *> *oldTogglesList = self.enabledToggles;
    NSMutableArray<NSString *> *newTogglesList = [NSMutableArray array];
    for (NSString *identifier in oldTogglesList) {
        // Exception for low power, data, wifi
        if ([identifier isEqualToString:@"wifi"]) {
            [newTogglesList addObject:@"com.shade.nougat.WiFiToggle"];
            continue;
        } else if ([identifier isEqualToString:@"cellular-data"]) {
            [newTogglesList addObject:@"com.shade.nougat.DataToggle"];
            continue;
        } else if ([identifier isEqualToString:@"low-power"]) {
            [newTogglesList addObject:@"com.shade.nougat.BatterySaverToggle"];
            continue;
        }

        // Get components
        NSArray<NSString *> *components = [identifier componentsSeparatedByString:@"-"];
        NSString *equivalentKey = @"";
        for (NSString *item in components) {
            // Capitalize first letter
            equivalentKey = [equivalentKey stringByAppendingString:item.capitalizedString];
        }

        // Construct and add key
        NSString *updatedKey = [NSString stringWithFormat:@"com.shade.nougat.%@Toggle", equivalentKey];
        [newTogglesList addObject:updatedKey];
    }

    // Add to prefs
    _preferences[NUAPreferencesTogglesListKey] = [newTogglesList copy];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.shade.nougat/ReloadPrefs"), NULL, NULL, YES);
}

- (BOOL)_hasBrokenMigration {
    // Check if toggles list has old keys
    return [self.enabledToggles containsObject:@"com.shade.nougat.CellularDataToggle"];
}

- (void)_fixBrokenMigration {
    // Gotta fix my dumbness now
    NSMutableArray<NSString *> *newTogglesList = [self.enabledToggles mutableCopy];
    [newTogglesList removeObject:@"com.shade.nougat.CellularDataToggle"];
    [newTogglesList removeObject:@"com.shade.nougat.LowPowerToggle"];
    [newTogglesList removeObject:@"com.shade.nougat.WifiToggle"];

    // Add to prefs
    _preferences[NUAPreferencesTogglesListKey] = [newTogglesList copy];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.shade.nougat/ReloadPrefs"), NULL, NULL, YES);
}

#pragma mark - First Time Helpers

- (void)setHasBeenPrompted {
    // Update prefs
    _preferences[NUAPreferencesFirstTimeUserKey] = @(NO);
}

#pragma mark - Convenience Methods

+ (BOOL)_deviceHasNotch {
    if (@available(iOS 11, *)) {
        LAContext* context = [[LAContext alloc] init];
        [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics 
                             error:nil];
                             
        return [context biometryType] == LABiometryTypeFaceID;
    }

    // Doesn't apply to before iOS 11
    return NO;
}

+ (NSString *)carrierName {
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = networkInfo.subscriberCellularProvider;
    return carrier.carrierName;
}

+ (NSArray<NSString *> *)_defaultEnabledToggles {
    return @[@"com.shade.nougat.WiFiToggle", @"com.shade.nougat.DataToggle", @"com.shade.nougat.BluetoothToggle", @"com.shade.nougat.DoNotDisturbToggle", @"com.shade.nougat.FlashlightToggle", @"com.shade.nougat.RotationLockToggle", @"com.shade.nougat.BatterySaverToggle", @"com.shade.nougat.LocationToggle", @"com.shade.nougat.AirplaneModeToggle"];
}

@end
