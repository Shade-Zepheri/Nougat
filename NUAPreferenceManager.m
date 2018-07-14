#import "NUAPreferenceManager.h"
#import "Macros.h"
#import <Cephei/HBPreferences.h>
#import <SpringBoard/SBDefaults.h>
#import <SpringBoard/SBExternalCarrierDefaults.h>
#import <SpringBoard/SBExternalDefaults.h>
#import <SpringBoard/SBWiFiManager.h>

@implementation NUAPreferenceManager {
    HBPreferences *_preferences;

    NUADrawerTheme _currentTheme;
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
        _preferences = [HBPreferences preferencesForIdentifier:@"com.shade.nougat"];

        [_preferences registerBool:&_enabled default:YES forKey:NUAPreferencesEnabledKey];
        [_preferences registerInteger:(NSInteger *)&_currentTheme default:NUADrawerThemeNexus forKey:NUAPreferencesCurrentThemeKey];

        NSArray<NSString *> *defaultToggleOrder = @[@"wifi", @"cellular-data", @"bluetooth", @"do-not-disturb", @"flashlight", @"rotation-lock", @"low-power", @"location", @"airplane-mode"];
        [_preferences registerObject:&_togglesList default:defaultToggleOrder forKey:NUAPreferencesTogglesListKey];

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(preferencesWereUpdated) name:HBPreferencesDidChangeNotification object:nil];
        [self preferencesWereUpdated];
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
            break;
        }
        case NUADrawerThemePixel: {
            _backgroundColor = PixelBackgroundColor;
            _highlightColor = PixelTintColor;
            _textColor = [UIColor whiteColor];
            break;
        }
        case NUADrawerThemeOreo: {
            _backgroundColor = OreoBackgroundColor;
            _highlightColor = OreoTintColor;
            _textColor = [UIColor blackColor];
            break;
        }
    }

    NSDictionary<NSString *, UIColor *> *colorInfo = @{@"backgroundColor": _backgroundColor, @"tintColor": _highlightColor, @"textColor": _textColor};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NUANotificationShadeChangedBackgroundColor" object:nil userInfo:colorInfo];
}

#pragma mark - Convenience Methods

+ (NSString *)currentWifiSSID {
    return [[NSClassFromString(@"SBWiFiManager") sharedInstance] currentNetworkName];
}

+ (NSString *)carrierName {
    //Could use CoreTelephony but lets use SB methods
    SBExternalDefaults *externalDefaults = [NSClassFromString(@"SBDefaults") externalDefaults];
    SBExternalCarrierDefaults *carrierDefaults = externalDefaults.carrierDefaults;

    return carrierDefaults.carrierName;
}

@end
