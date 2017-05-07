#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NUAToggleType) {

    NUAToggleTypeWifi,
    NUAToggleTypeCellularData,
    NUAToggleTypeBattery,
    NUAToggleTypeTorch,
    NUAToggleTypeAirplaneMode,
    NUAToggleTypeRotationLock,
    NUAToggleTypeBluetooth,
    NUAToggleTypeDoNotDisturb,
    NUAToggleTypeLocation,
};

@interface NUADrawerPanelButton : UIView {
  BOOL _toggled;
}
@property (strong, nonatomic) UIImage *toggleImage;
@property (readonly, nonatomic) NUAToggleType toggleType;
- (instancetype)initWithFrame:(CGRect)frame withType:(NUAToggleType)type;
@end
