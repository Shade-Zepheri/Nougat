#import "NUAToggleInstancesProvider.h"
#import <HBLog.h>

@implementation NUAToggleInstancesProvider

#pragma mark - Init

+ (instancetype)defaultProvider {
    static NUAToggleInstancesProvider *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] initWithPreferences:[NUAPreferenceManager sharedSettings]];
    });

    return sharedInstance;
}

- (instancetype)initWithPreferences:(NUAPreferenceManager *)preferences {
    self = [super init];
    if (self) {
        self.preferences = preferences;
        _toggleInstances = [NSArray array];

        [self _populateToggles];
    }

    return self;
}

#pragma mark - Toggles

- (void)_populateToggles {
    NSMutableArray<NUAFlipswitchToggle *> *populatedToggles = [NSMutableArray array];

    NSArray<NSString *> *enabledToggles = [self.preferences _installedToggleIdentifiers];
    for (NSString *identifier in enabledToggles) {
        NUAToggleInfo *info = [self.preferences toggleInfoForIdentifier:identifier];
        if (!info) {
            continue;
        }

        NUAFlipswitchToggle *toggle = [self _createToggleFromInfo:info];
        if (!toggle) {
            continue;
        }

        [populatedToggles addObject:toggle];
    }

    _toggleInstances = [populatedToggles copy];
}

- (NUAFlipswitchToggle *)_createToggleFromInfo:(NUAToggleInfo *)info {
    NSBundle *bundle = [NSBundle bundleWithURL:info.bundleURL];
    if (!bundle) {
        return nil;
    }

    if (!bundle.loaded) {
        // Load bundle
        NSError *error = nil;
        BOOL loaded = [bundle loadAndReturnError:&error];
        if (loaded) {
            // Create toggle
            return [[bundle.principalClass alloc] init];
        } else {
            HBLogError(@"Toggle loading error: %@", error);
        }
    } else {
        return [[bundle.principalClass alloc] init];
    }

    return nil;
}

@end