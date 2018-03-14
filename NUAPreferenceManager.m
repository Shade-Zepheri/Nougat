#import "NUAPreferenceManager.h"
#import "Macros.h"
#import <Cephei/HBPreferences.h>
#import <SpringBoard/SBDefaults.h>
#import <SpringBoard/SBExternalCarrierDefaults.h>
#import <SpringBoard/SBExternalDefaults.h>
#import <SpringBoard/SBWiFiManager.h>

// Settings keys
static NSString *const NUAPreferencesEnabledKey = @"enabled";

static NSString *const NUAPreferencesQuickPanelOrderKey = @"quickToggleOrder";
static NSString *const NUAPreferencesMainPanelOrderKey = @"mainPanelOrder";

static NSString *const NUAPreferencesCurrentThemeKey = @"darkVariant";

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

        [_preferences registerBool:&_enabled default:YES forKey:VLYPreferencesEnabledKey];
        [_preferences registerInteger:(NSInteger *)&_currentTheme default:NUADrawerThemeNexus forKey:NUAPreferencesCurrentThemeKey];

        NSArray *defaultQuickOrder = @[@"wifi", @"cellular-data", @"bluetooth", @"do-not-disturb", @"flashlight", @"rotation-lock"];
        NSArray *defaultMainOrder = @[@"wifi", @"cellular-data", @"bluetooth", @"do-not-disturb", @"flashlight", @"rotation-lock", @"low-power", @"location", @"airplane-mode"];

        [_preferences registerObject:&_quickToggleOrder default:defaultQuickOrder forKey:NUAPreferencesQuickPanelOrderKey];
        [_preferences registerObject:&_mainPanelOrder default:defaultMainOrder forKey:NUAPreferencesMainPanelOrderKey];

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(preferencesWereUpdated) name:HBPreferencesDidChangeNotification object:nil];
        [self preferencesWereUpdated];
    }

    return self;
}

#pragma mark - Callbacks

- (void)preferencesWereUpdated {
    switch ((NUADrawerTheme)colorTag) {
        case NUADrawerThemeNexus: {
            _backgroundColor = NexusBackgroundColor;
            _highlightColor = NexusTintColor;
            break;
        }
        case NUADrawerThemePixel: {
            _backgroundColor = PixelBackgroundColor;
            _highlightColor = PixelTintColor;
            break;
        }
        case NUADrawerThemeOreo: {
            _backgroundColor = OreoBackgroundColor;
            _highlightColor = OreoTintColor;
            break;
        }
    }

    NSDictionary *colorInfo = @{@"backgroundColor": _backgroundColor, @"tintColor": _highlightColor};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NUANotificationShadeChangedBackgroundColor" object:nil userInfo:colorInfo];
}

#pragma mark - Convenient Methods

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
