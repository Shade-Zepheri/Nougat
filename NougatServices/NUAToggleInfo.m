#import "NUAToggleInfo.h"
#import <UIKit/UIImage+Private.h>

@implementation NUAToggleInfo

#pragma mark - Init

+ (instancetype)toggleInfoWithBundleURL:(NSURL *)bundleURL {
    return [[self alloc] initWithBundleURL:bundleURL];
}

- (instancetype)initWithBundleURL:(NSURL *)bundleURL {
    self = [super init];
    if (self) {
        _bundleURL = bundleURL;

        NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];
        _identifier = [bundle objectForInfoDictionaryKey:@"CFBundleIdentifier"];
        _displayName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    }

    return self;
}

#pragma mark - Properties

- (UIImage *)settingsIcon {
    // Init on demand because init is called from ctor and creating images causes crashes
    NSBundle *bundle = [NSBundle bundleWithURL:self.bundleURL];
    UIImage *settingsIcon = [UIImage imageNamed:@"SettingsIcon" inBundle:bundle];
    if (!settingsIcon) {
        // Provide fallback icon
        settingsIcon = [UIImage imageNamed:@"FallbackSettingsIcon" inBundle:[NSBundle bundleForClass:[self class]]];
    }

    return settingsIcon;
}

@end