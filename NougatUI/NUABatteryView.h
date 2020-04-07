#import <UIKit/UIKit.h>
#import <NougatServices/NougatServices.h>

@interface NUABatteryView : UIView 
@property (strong, readonly, nonatomic) NUAPreferenceManager *notificationShadePreferences;
@property (assign, nonatomic) CGFloat currentPercent;
@property (getter=isCharging, assign, nonatomic) BOOL charging;
@property (strong, readonly, nonatomic) UIImageView *chargingImage;

- (instancetype)initWithFrame:(CGRect)frame andPercent:(CGFloat)percent preferences:(NUAPreferenceManager *)preferences;

@end