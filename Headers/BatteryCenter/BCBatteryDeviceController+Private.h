#import <BatteryCenter/BCBatteryDeviceController.h>
#import "BCBatteryDeviceObserving.h"

@interface BCBatteryDeviceController ()

// iOS 14
- (void)addBatteryDeviceObserver:(id<BCBatteryDeviceObserving>)observer queue:(dispatch_queue_t)queue;
- (void)removeBatteryDeviceObserver:(id<BCBatteryDeviceObserving>)observer;

@end