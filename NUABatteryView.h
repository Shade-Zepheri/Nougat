#import <UIKit/UIKit.h>

@interface NUABatteryView : UIView 
@property (assign, nonatomic) CGFloat currentPercent;
@property (getter=isCharging, assign, nonatomic) BOOL charging;
@property (strong, readonly, nonatomic) UIImageView *batteryImageView;

- (instancetype)initWithFrame:(CGRect)frame andPercent:(CGFloat)percent;

@end