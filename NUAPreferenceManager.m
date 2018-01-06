#import "headers.h"
#import "NUAPreferenceManager.h"

void reloadSettings(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
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
        NSInteger colorTag = ![_settings objectForKey:@"darkVariant"] ? 1 : [[_settings objectForKey:@"darkVariant"] intValue];
        _backgroundColor = colorTag == 1 ? NexusDarkColor : PixelDarkColor;
        _highlightColor = colorTag == 1 ? NexusTintColor : PixelTintColor;

        NSDictionary *colorInfo = @{@"backgroundColor": _backgroundColor, @"tintColor": _highlightColor};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Nougat/BackgroundColorChange" object:nil userInfo:colorInfo];
    }
}

+ (NSString *)currentWifiSSID {
    return [[objc_getClass("SBWiFiManager") sharedInstance] currentNetworkName];
}

@end
