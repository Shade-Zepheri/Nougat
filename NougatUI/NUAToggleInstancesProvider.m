#import "NUAToggleInstancesProvider.h"
#import <HBLog.h>

@interface NUAToggleInstancesProvider () {
    dispatch_queue_t _queue;
}
@property (strong, nonatomic) NSHashTable<id<NUAToggleInstancesProviderObserver>> *observers;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NUAToggleInstance *> *toggleInstanceByIdentifier;
@property (strong, nonatomic) NUAPreferenceManager *notificationShadePreferences;

@end

@implementation NUAToggleInstancesProvider

#pragma mark - Initialization

- (instancetype)initWithPreferences:(NUAPreferenceManager *)preferences {
    self = [super init];
    if (self) {
        // Create properties
        _notificationShadePreferences = preferences;
        _observers = [NSHashTable weakObjectsHashTable];
        _toggleInstanceByIdentifier = [NSMutableDictionary dictionary];

        // Create thread
        dispatch_queue_attr_t attributes = dispatch_queue_attr_make_with_autorelease_frequency(DISPATCH_QUEUE_SERIAL, DISPATCH_AUTORELEASE_FREQUENCY_WORK_ITEM);
        _queue = dispatch_queue_create("com.shade.nougat.ToggleInstancesProvider", attributes);

        [self _populateToggles];

        // Register for notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferencesDidChange:) name:@"NUANotificationShadeChangedPreferences" object:nil];
    }

    return self;
}

#pragma mark - Properties

- (NSArray<NUAToggleInstance *> *)toggleInstances {
    return self.toggleInstanceByIdentifier.allValues;
}

#pragma mark - Toggle Management

- (void)_populateToggles {
    // Determine what toggles to use
    NSSet<NSString *> *currentIdentifiers = [NSSet setWithArray:self.toggleInstanceByIdentifier.allKeys];
    NSSet<NSString *> *enabledIdentifiers = [NSSet setWithArray:self.notificationShadePreferences.enabledToggleIdentifiers];

    // Determine toggles to remove
    NSMutableSet<NSString *> *identifiersToRemove = [currentIdentifiers mutableCopy];
    [identifiersToRemove minusSet:enabledIdentifiers];

    [self.toggleInstanceByIdentifier removeObjectsForKeys:identifiersToRemove.allObjects];

    // Determine if toggles need to be loaded
    NSMutableSet<NSString *> *identifiersToLoad = [enabledIdentifiers mutableCopy];
    [identifiersToLoad minusSet:currentIdentifiers];

    if (identifiersToLoad.count == 0 && identifiersToRemove.count == 0) {
        // Nothing to load or remove
        return;
    }

    // Construct instances
    __block NSMutableArray<NUAToggleInfo *> *toggleInfoArray = [NSMutableArray array];
    for (NSString *identifier in identifiersToLoad) {
        NUAToggleInfo *toggleInfo = [self.notificationShadePreferences toggleInfoForIdentifier:identifier];
        [toggleInfoArray addObject:toggleInfo];
    }

    [self _loadBundlesForToggleInfo:toggleInfoArray withCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            // Create dictionary
            for (NUAToggleInfo *toggleInfo in toggleInfoArray) {
                NUAToggleInstance *toggleInstance = [self _instantiateToggleWithInfo:toggleInfo];
                if (!toggleInstance) {
                    // Couldn't generate
                    continue;
                }

                self.toggleInstanceByIdentifier[toggleInfo.toggleIdentifier] = toggleInstance;
            }

            // Notify observers
            [self _runBlockOnObservers:^(id<NUAToggleInstancesProviderObserver> observer) {
                [observer toggleInstancesChangedForToggleInstancesProvider:self];
            }];
        });
    }];
}

- (NUAToggleInstance *)_instantiateToggleWithInfo:(NUAToggleInfo *)toggleInfo {
    NSBundle *bundle = [NSBundle bundleWithURL:toggleInfo.toggleBundleURL];
    if (!bundle.loaded) {
        // Should be loaded by now
        HBLogError(@"Attempting to load toggle whose bundle has not been loaded");
        return nil;
    }

    if (![bundle.principalClass isSubclassOfClass:[NUAToggleButton class]]) {
        // Not toggle class
        HBLogError(@"Toggle bundle's principal class is an unsupported class, will unload bundle");
        [bundle unload];
        return nil;
    }

    NUAToggleButton *toggleButton = [[bundle.principalClass alloc] init];
    if (!toggleButton) {
        // Couldnt instantiate class
        HBLogError(@"Toggle's init method returned nil, will unload bundle");
        [bundle unload];
        return nil;
    }

    // Feed prefs to toggle
    toggleButton.notificationShadePreferences = self.notificationShadePreferences;
    return [[NUAToggleInstance alloc] initWithToggleInfo:toggleInfo toggle:toggleButton];
}

#pragma mark - Bundle Loading

- (NSArray<NSBundle *> *)_loadBundlesForToggleInfo:(NSArray<NUAToggleInfo *> *)toggleInfoArray {
    // Load any potentially unloaded bundles
    NSMutableArray<NSBundle *> *loadedBundles = [NSMutableArray array];
    for (NUAToggleInfo *toggleInfo in toggleInfoArray) {
        NSBundle *bundle = [NSBundle bundleWithURL:toggleInfo.toggleBundleURL];
        if (bundle.loaded) {
            // Already loaded, nothing to do
            continue;
        }

        NSError *error = nil;
        BOOL loaded = [bundle loadAndReturnError:&error];
        if (!loaded) {
            // Couldn't load
            HBLogError(@"Bundle was not loaded, error = %@", error);
            continue;
        }

        [loadedBundles addObject:bundle];
    }

    return [loadedBundles copy];
}

- (void)_loadBundlesForToggleInfo:(NSArray<NUAToggleInfo *> *)toggleInfoArray withCompletionHandler:(void(^)(void))completionHandler {
    // Load bundles and call a completion
    dispatch_async(_queue, ^{
        [self _loadBundlesForToggleInfo:toggleInfoArray];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (!completionHandler) {
                return;
            }

            completionHandler();
        });
    });
}

#pragma mark - Observers

- (void)addObserver:(id<NUAToggleInstancesProviderObserver>)observer {
    if ([self.observers containsObject:observer]) {
        return;
    }

    [self.observers addObject:observer];
}

- (void)removeObserver:(id<NUAToggleInstancesProviderObserver>)observer {
    if (![self.observers containsObject:observer]) {
        return;
    }

    [self.observers removeObject:observer];
}

- (void)_runBlockOnObservers:(NUAToggleInstancesProviderObserverBlock)block {
    for (id<NUAToggleInstancesProviderObserver> observer in self.observers.allObjects) {
        block(observer);
    }
}

#pragma mark - Notifications

- (void)preferencesDidChange:(NSNotification *)notification {
    // Refresh toggles list
    [self _populateToggles];
}

@end