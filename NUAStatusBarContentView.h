#import <UIKit/UIKit.h>
#import "NUABatteryView.h"

@interface NUAStatusBarContentView : UIView
@property (strong, nonatomic) NSDate *date;
@property (assign, nonatomic) CGFloat currentPercent;
@property (getter=isCharging, assign, nonatomic) BOOL charging;

@property (strong, readonly, nonatomic) NUABatteryView *batteryView;
@property (strong, readonly, nonatomic) UILabel *carrierLabel;
@property (strong, readonly, nonatomic) UILabel *batteryLabel;
@property (strong, readonly, nonatomic) UILabel *dateLabel;

- (void)updateFormat;

@end