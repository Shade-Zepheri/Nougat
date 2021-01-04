#import <UIKit/UIKit.h>

@class BCBatteryDevice;

@protocol BCBatteryDeviceObserving <NSObject>
@optional

- (void)connectedDevicesDidChange:(NSArray<BCBatteryDevice *> *)connectedDevices;

@end