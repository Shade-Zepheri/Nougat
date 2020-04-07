#import "NUAToggleInstancesProvider.h"
#import <HBLog.h>

@implementation NUAToggleInstancesProvider

#pragma mark - Initialization

- (instancetype)initWithPreferences:(NUAPreferenceManager *)preferences {
    self = [super init];
    if (self) {
        _notificationShadePreferences = preferences;
        _toggleInstances = [NSArray array];

        [self _populateToggles];

        // Register for notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferencesDidChange:) name:@"NUANotificationShadeChangedPreferences" object:nil];
    }

    return self;
}

#pragma mark - Toggles

- (void)_populateToggles {
    NSMutableArray<NUAFlipswitchToggle *> *populatedToggles = [NSMutableArray array];

    NSArray<NSString *> *enabledToggles = self.notificationShadePreferences.enabledToggles;
    for (NSString *identifier in enabledToggles) {
        NUAToggleInfo *info = [self.notificationShadePreferences toggleInfoForIdentifier:identifier];
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

#pragma mark - Notifications

- (void)preferencesDidChange:(NSNotification *)notification {
    // Refresh toggles list
    [self _populateToggles];
}

@end