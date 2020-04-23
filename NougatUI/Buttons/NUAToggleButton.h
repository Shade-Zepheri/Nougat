#import <UIKit/UIKit.h>
#import <NougatServices/NougatServices.h>

@class NUAToggleButton;

@protocol NUAToggleButtonDelegate <NSObject>

- (void)toggleWantsNotificationShadeDismissal:(NUAToggleButton *)toggleButton;

@end

@interface NUAToggleButton : UIView
@property (weak, nonatomic) id<NUAToggleButtonDelegate> delegate;
@property (strong, nonatomic) NUAPreferenceManager *notificationShadePreferences;
@property (strong, readonly, nonatomic) UILabel *displayNameLabel;

@property (getter=isSelected, nonatomic) BOOL selected;
@property (getter=isEnabled, nonatomic) BOOL enabled;

@property (getter=isInverted, readonly, nonatomic) BOOL inverted;
@property (getter=isUsingDark, readonly, nonatomic) BOOL usingDark;
@property (strong, readonly, nonatomic) NSURL *settingsURL;
@property (copy, readonly, nonatomic) NSString *displayName;
@property (strong, readonly, nonatomic) UIImage *icon;
@property (strong, readonly, nonatomic) UIImage *selectedIcon;

- (void)refreshAppearance;

@end