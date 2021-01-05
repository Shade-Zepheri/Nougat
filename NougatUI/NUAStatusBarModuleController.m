#import "NUAStatusBarModuleController.h"
#import "NUAStatusBarContentView.h"

@interface NUAStatusBarModuleController ()
@property (strong, nonatomic) BCBatteryDeviceController *batteryDeviceController;

@end

@implementation NUAStatusBarModuleController

#pragma mark - NUANotificationShadeModuleViewController

+ (Class)viewClass {
    return NUAStatusBarContentView.class;
}

- (NSString *)moduleIdentifier {
    return @"com.shade.nougat.statusbar";
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Hide/Show view
    self.view.alpha = self.notificationShadePreferences.hideStatusBarModule ? 0.0 : 1.0;

    // Create battery controller
    _batteryDeviceController = [[BCBatteryDeviceController alloc] init];

    // Register for notifications
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(_updateFormat) name:@"BSDateTimeCacheChangedNotification" object:nil];
    [center addObserver:self selector:@selector(preferencesDidChange:) name:@"NUANotificationShadeChangedPreferences" object:nil];

    // Register for time updates
    _timeManager = [NUAPreciseTimerManager sharedManager];
    [self statusBarView].date = [NSDate date];
    if (!_disablesUpdates) {
        [self _startTimeUpdates];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Register for battery updates
    if ([self.batteryDeviceController respondsToSelector:@selector(addBatteryDeviceObserver:queue:)]) {
        // iOS 14
        [self.batteryDeviceController addBatteryDeviceObserver:self queue:dispatch_get_main_queue()];
    } else {
        // iOS 10-13
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_connectedDevicesDidChange:) name:self.batteryDeviceController.connectedDevicesDidChangeNotificationName object:nil];

        // Add handler
        __weak __typeof(self) weakSelf = self;
        [self.batteryDeviceController addDeviceChangeHandler:^(BCBatteryDevice *device) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!device.internal) {
                    return;
                }

                [weakSelf _updateBatteryStateWithDevice:device];
            });
        } withIdentifier:self.moduleIdentifier];

        // Manually pass first update
        BCBatteryDevice *internalDevice = [self _internalDevice];
        [self _updateBatteryStateWithDevice:internalDevice];
    }

    // Start updates
    [self _setDisablesUpdates:NO];

    [self statusBarView].date = [NSDate date];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // Stop battery updates
    if ([self.batteryDeviceController respondsToSelector:@selector(removeBatteryDeviceObserver:)]) {
        // iOS 14
        [self.batteryDeviceController removeBatteryDeviceObserver:self];
    } else {
        // iOS 10-13
        [[NSNotificationCenter defaultCenter] removeObserver:self name:self.batteryDeviceController.connectedDevicesDidChangeNotificationName object:nil];

        [self.batteryDeviceController removeDeviceChangeHandlerWithIdentifier:self.moduleIdentifier];
    }

    // Stop updates
    [self _setDisablesUpdates:YES];
}

- (NUAStatusBarContentView *)statusBarView {
    return (NUAStatusBarContentView *)self.view;
}

#pragma mark - Time Management

- (void)managerUpdatedWithDate:(NSDate *)date {
    // Pass to label
    [self _updateLabelWithDate:date];
}

- (void)_setDisablesUpdates:(BOOL)disablesUpdates {
    if (_disablesUpdates == disablesUpdates) {
        return;
    }

    _disablesUpdates = disablesUpdates;

    if (_disablesUpdates) {
        [self _stopTimeUpdates];
    } else {
        [self _startTimeUpdates];
    }
}

- (void)_stopTimeUpdates {
    // Remove self as observer
    [self.timeManager removeObserver:self];
}

- (void)_startTimeUpdates {
    // Add self as observer
    [self.timeManager addObserver:self];
}

#pragma mark - View Management

- (void)_updateLabelWithDate:(NSDate *)date {
    if (_disablesUpdates) {
      [self _stopTimeUpdates];
    } else {
        [self statusBarView].date = date;
        [self _startTimeUpdates];
    }
}

#pragma mark - Battery Management

- (BCBatteryDevice *)_internalDevice {
    NSArray<BCBatteryDevice *> *connectedDevices = self.batteryDeviceController.connectedDevices;
    NSUInteger internalDeviceIndex = [connectedDevices indexOfObjectPassingTest:^(BCBatteryDevice *device, NSUInteger idx, BOOL *stop) {
        return device.internal;
    }];
    return connectedDevices[internalDeviceIndex];
}

- (void)_updateBatteryStateWithDevice:(BCBatteryDevice *)device {
    [self statusBarView].currentPercent = device.percentCharge / 100.0;
    [self statusBarView].charging = device.charging;
}

#pragma mark - BCBatteryDeviceObserving

- (void)connectedDevicesDidChange:(NSArray<BCBatteryDevice *> *)connectedDevices {
    // Get internal device
    NSUInteger internalDeviceIndex = [connectedDevices indexOfObjectPassingTest:^(BCBatteryDevice *device, NSUInteger idx, BOOL *stop) {
        return device.internal;
    }];
    BCBatteryDevice *internalDevice = connectedDevices[internalDeviceIndex];

    // Update info
    [self _updateBatteryStateWithDevice:internalDevice];
}

#pragma mark - Notifications

- (void)_updateFormat {
    if (_disablesUpdates) {
        return;
    }

    [[self statusBarView] updateFormat];

    [self _updateLabelWithDate:[NSDate date]];
}

- (void)preferencesDidChange:(NSNotification *)notification {
    // Hide/Show view
    self.view.alpha = self.notificationShadePreferences.hideStatusBarModule ? 0.0 : 1.0;
}

- (void)_connectedDevicesDidChange:(NSNotification *)notification {
    // Pass latest state
    BCBatteryDevice *internalDevice = [self _internalDevice];
    [self _updateBatteryStateWithDevice:internalDevice];
}

@end