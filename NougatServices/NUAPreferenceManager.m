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

        NSArray<NSString *> *defaultToggleOrder = @[@"com.shade.nougat.WiFiToggle", @"com.shade.nougat.DataToggle", @"com.shade.nougat.BluetoothToggle", @"com.shade.nougat.DoNotDisturbToggle", @"com.shade.nougat.FlashlightToggle", @"com.shade.nougat.RotationLockToggle", @"com.shade.nougat.BatterySaverToggle", @"com.shade.nougat.LocationToggle", @"com.shade.nougat.AirplaneModeToggle"];
        [_preferences registerObject:&_enabledToggles default:defaultToggleOrder forKey:NUAPreferencesTogglesListKey];

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(preferencesWereUpdated) name:HBPreferencesDidChangeNotification object:nil];
        [self preferencesWereUpdated];

        [self refreshToggleInfo];
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

#pragma mark - Convenience Methods

+ (NSString *)carrierName {
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    return carrier.carrierName;
}

@end
