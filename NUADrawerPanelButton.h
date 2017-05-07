#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NUAToggleType) {
    NUAToggleTypeAirplaneMode,
    NUAToggleTypeWifi,
    NUAToggleTypeCellularData,
    NUAToggleTypeTorch,
    NUAToggleTypeRotationLock,
    NUAToggleTypeBattery,
    NUAToggleTypeBluetooth,
    NUAToggleTypeDoNotDisturb,
    NUAToggleTypeLocation,
};

@interface NUADrawerPanelButton : UIView {
  BOOL _toggled;
}
@property (strong, nonatomic) UIImage *toggleImage;
@property (readonly, nonatomic) NUAToggleType toggleType;
@end
