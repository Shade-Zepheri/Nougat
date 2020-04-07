#import <UIKit/UIKit.h>
#import <NougatServices/NougatServices.h>

@interface NUANotificationShadePanelView : UIView
@property (strong, readonly, nonatomic) NUAPreferenceManager *notificationShadePreferences;

@property (strong, nonatomic) UIView *contentView;
@property (assign, nonatomic) CGFloat inset;
@property (assign, nonatomic) CGFloat revealPercentage;
@property (assign, nonatomic) CGFloat fullyPresentedHeight;

@property (strong, nonatomic) NSLayoutConstraint *insetConstraint;

- (instancetype)initWithPreferences:(NUAPreferenceManager *)preferences;

@end