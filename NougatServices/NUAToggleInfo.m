#import "NUAToggleInfo.h"

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

@end