#import <UIKit/UIKit.h>
#import <SpringBoard/SBDateTimeOverrideObserver.h>

@interface NUAStatusBar : UIView <SBDateTimeOverrideObserver> {
    //Really just copying SBLockScreenDateViewController
    NSNumber *_timerToken;
    BOOL _disablesUpdates;
}

@property (strong, readonly, nonatomic) NSBundle *resourceBundle;
@property (strong, readonly, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, readonly, nonatomic) UILabel *dateLabel;
@property (strong, readonly, nonatomic) UIButton *toggleButton;

- (void)updateToggle:(BOOL)toggled;
- (void)updateTimeWithDate:(NSDate *)date;

@end
