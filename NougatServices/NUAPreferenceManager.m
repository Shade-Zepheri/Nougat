#import "NUAPreferenceManager.h"
#import <Macros.h>
#import <Cephei/HBPreferences.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

@implementation NUAPreferenceManager {
    HBPreferences *_preferences;

    NUADrawerTheme _currentTheme;
    NSMutableDictionary<NSString *, NUAToggleInfo *> *_toggleInfoDictionary;
}

+ (instancetype)sharedSettings {
    static NUAPreferenceManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _toggleInfoDictionary = [NSMutableDictionary dictionary];

        _preferences = [HBPreferences preferencesForIdentifier:@"com.shade.nougat"];

        [_preferences registerBool:&_enabled default:YES forKey:NUAPreferencesEnabledKey];
        [_preferences registerInteger:(NSInteger *)&_currentTheme default:NUADrawerThemeNexus forKey:NUAPreferencesCurrentThemeKey];
        [_preferences registerBool:&_useExternalColor default:NO forKey:NUAPreferencesUsesExternalColorKey];

        NSArray<NSString *> *defaultToggleOrder = [self _defaultEnabledToggles];
        [_preferences registerObject:&_enabledToggles default:defaultToggleOrder forKey:NUAPreferencesTogglesListKey];

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(preferencesWereUpdated) name:HBPreferencesDidChangeNotification object:nil];
        [self preferencesWereUpdated];

        [self refreshToggleInfo];

        if ([self _hasLegacyPrefs]) {
            [self _migrateFromLegacyPrefs];
        }
    }

    return self;
}

#pragma mark - Callbacks

- (void)preferencesWereUpdated {
    switch (_currentTheme) {
        case NUADrawerThemeNexus: {
            _backgroundColor = NexusBackgroundColor;
            _highlightColor = NexusTintColor;
            _textColor = [UIColor whiteColor];
            _usingDark = NO;
            break;
        }
        case NUADrawerThemePixel: {
            _backgroundColor = PixelBackgroundColor;
            _highlightColor = PixelTintColor;
            _textColor = [UIColor whiteColor];
            _usingDark = NO;
            break;
        }
        case NUADrawerThemeOreo: {
            _backgroundColor = OreoBackgroundColor;
            _highlightColor = OreoTintColor;
            _textColor = [UIColor blackColor];
            _usingDark = YES;
            break;
        }
    }

    [self refreshToggleInfo];

    NSDictionary<NSString *, UIColor *> *colorInfo = @{@"backgroundColor": _backgroundColor, @"tintColor": _highlightColor, @"textColor": _textColor};
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
        HBLogError(@"%@", error);
    }

    NSMutableArray<NSString *> *disabledToggles = [NSMutableArray array];
    // Construct disabled toggles
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
        } else if ([identifier isEqualToString:@"cellular-data"]) {
            [newTogglesList addObject:@"com.shade.nougat.DataToggle"];
        } else if ([identifier isEqualToString:@"low-power"]) {
            [newTogglesList addObject:@"com.shade.nougat.BatterySaverToggle"];
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
    [_preferences setObject:[newTogglesList copy] forKey:NUAPreferencesTogglesListKey];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.shade.nougat/ReloadPrefs"), NULL, NULL, YES);
}

#pragma mark - Convenience Methods

+ (NSString *)carrierName {
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    return carrier.carrierName;
}

- (NSArray<NSString *> *)_defaultEnabledToggles {
    return @[@"com.shade.nougat.WiFiToggle", @"com.shade.nougat.DataToggle", @"com.shade.nougat.BluetoothToggle", @"com.shade.nougat.DoNotDisturbToggle", @"com.shade.nougat.FlashlightToggle", @"com.shade.nougat.RotationLockToggle", @"com.shade.nougat.BatterySaverToggle", @"com.shade.nougat.LocationToggle", @"com.shade.nougat.AirplaneModeToggle"];
}

@end
