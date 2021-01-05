#import <BatteryCenter/BCBatteryDeviceController.h>
#import "BCBatteryDeviceObserving.h"

typedef void (^BCBatteryDeviceChangedHandler)(BCBatteryDevice *device);

@interface BCBatteryDeviceController ()

// iOS 10-13
- (void)addDeviceChangeHandler:(BCBatteryDeviceChangedHandler)handler withIdentifier:(NSString *)identifier;

// iOS 14
- (void)addBatteryDeviceObserver:(id<BCBatteryDeviceObserving>)observer queue:(dispatch_queue_t)queue;
- (void)removeBatteryDeviceObserver:(id<BCBatteryDeviceObserving>)observer;

@end