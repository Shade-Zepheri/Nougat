#import "headers.h"
#import "NUAPreferenceManager.h"

void reloadSettings() {
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
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadSettings, CFSTR("com.shade.nougat/ReloadPrefs"), NULL, CFNotificationSuspensionBehaviorCoalesce);
        [self reloadSettings];
    }

    return self;
}

- (void)reloadSettings {
    @autoreleasepool {
        if (_settings) {
            _settings = nil;
        }
        CFPreferencesAppSynchronize(CFSTR("com.shade.nougat"));
        CFStringRef appID = CFSTR("com.shade.nougat");
        CFArrayRef keyList = CFPreferencesCopyKeyList(appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);

        BOOL failed = NO;

        if (keyList) {
            _settings = (NSDictionary*)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
            CFRelease(keyList);

            if (!_settings) {
                failed = YES;
            }
        } else {
            failed = YES;
        }
        CFRelease(appID);

        if (failed) {
            _settings = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.shade.nougat.plist"];
        }

        if (!_settings) {
            HBLogError(@"could not load settings from CFPreferences or NSDictionary");
        }

        _enabled = ![_settings objectForKey:@"enabled"] ? YES : [[_settings objectForKey:@"enabled"] boolValue];
        NSInteger colorTag = ![_settings objectForKey:@"lightOrDark"] ? 1 : [[_settings objectForKey:@"lightOrDark"] intValue];
        _backgroundColor = colorTag == 1 ? NougatDarkColor : NougatLightColor;

        [[NSNotificationCenter defaultCenter] postNotificationName:@"Nougat/BackgroundColorChange" object:nil];
    }
}

@end
