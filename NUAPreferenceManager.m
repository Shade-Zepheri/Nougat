#import "NUAPreferenceManager.h"
#import "Macros.h"
#import <SpringBoard/SBDefaults.h>
#import <SpringBoard/SBExternalCarrierDefaults.h>
#import <SpringBoard/SBExternalDefaults.h>
#import <SpringBoard/SBWiFiManager.h>

static inline void reloadSettings(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    [[NUAPreferenceManager sharedSettings] reloadSettings];
}

@implementation NUAPreferenceManager

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
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, reloadSettings, CFSTR("com.shade.nougat/ReloadPrefs"), NULL, CFNotificationSuspensionBehaviorCoalesce);
        [self reloadSettings];
    }

    return self;
}

- (void)reloadSettings {
    @autoreleasepool {
        _settings = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.shade.nougat.plist"];

        NSArray *defaultQuickOrder = @[@"wifi", @"cellular-data", @"bluetooth", @"do-not-disturb", @"flashlight", @"rotation-lock"];
        NSArray *defaultMainOrder = @[@"wifi", @"cellular-data", @"bluetooth", @"do-not-disturb", @"flashlight", @"rotation-lock", @"low-power", @"location", @"airplane-mode"];

        _quickToggleOrder = ![_settings objectForKey:@"quickToggleOrder"] ? defaultQuickOrder : [_settings objectForKey:@"quickToggleOrder"];
        _mainPanelOrder = ![_settings objectForKey:@"mainPanelOrder"] ? defaultMainOrder : [_settings objectForKey:@"mainPanelOrder"];

        _enabled = ![_settings objectForKey:@"enabled"] ? YES : [[_settings objectForKey:@"enabled"] boolValue];
        NSInteger colorTag = ![_settings objectForKey:@"darkVariant"] ? 0 : [[_settings objectForKey:@"darkVariant"] intValue];

        switch ((NUADrawerTheme)colorTag) {
            case NUADrawerThemeNexus:
                _backgroundColor = NexusBackgroundColor;
                _highlightColor = NexusTintColor;
                break;
            case NUADrawerThemePixel:
                _backgroundColor = PixelBackgroundColor;
                _highlightColor = PixelTintColor;
                break;
            case NUADrawerThemeOreo:
                _backgroundColor = OreoBackgroundColor;
                _highlightColor = OreoTintColor;
                break;
        }

        NSDictionary *colorInfo = @{@"backgroundColor": _backgroundColor, @"tintColor": _highlightColor};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Nougat/BackgroundColorChange" object:nil userInfo:colorInfo];
    }
}

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
