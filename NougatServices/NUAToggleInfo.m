#import "NUAToggleInfo.h"
#import <UIKit/UIImage+Private.h>

@implementation NUAToggleInfo

#pragma mark - Class Helpers

+ (BOOL)_isCompatibleWithVersion:(NSString *)version {
    // Check version number
    NSString *currentVersion = [UIDevice currentDevice].systemVersion;
    return [currentVersion compare:version options:NSNumericSearch] != NSOrderedAscending;
}

#pragma mark - Initialization

+ (instancetype)toggleInfoForBundleAtURL:(NSURL *)bundleURL {
    // Do some checking first
    NSDictionary<NSString *, id> *infoDictionary = (__bridge_transfer NSDictionary *)CFBundleCopyInfoDictionaryInDirectory((__bridge CFURLRef)bundleURL);
    NSString *identifier = infoDictionary[@"CFBundleIdentifier"];
    NSString *minimumVersion = infoDictionary[@"MinimumOSVersion"];
    if (!identifier || ![self _isCompatibleWithVersion:minimumVersion]) {
        // No identifier, or not supported
        return nil;
    } else {
        // Pass to init
        return [[self alloc] _initWithIdentifier:identifier toggleBundleURL:bundleURL];
    }
}

- (instancetype)_initWithIdentifier:(NSString *)identifier toggleBundleURL:(NSURL *)bundleURL {
    self = [super init];
    if (self) {
        // Set defaults
        _identifier = [identifier copy];
        _bundleURL = [bundleURL copy];

        // Get additional info from bundle
        NSBundle *bundle = [NSBundle bundleWithURL:_bundleURL];
        _displayName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];

        UIImage *settingsIcon = [UIImage imageNamed:@"SettingsIcon" inBundle:bundle];
        if (!settingsIcon) {
            // Provide fallback icon
            settingsIcon = [UIImage imageNamed:@"FallbackSettingsIcon" inBundle:[NSBundle bundleForClass:self.class]];
        }

        _settingsIcon = settingsIcon;
    }

    return self;
}

@end