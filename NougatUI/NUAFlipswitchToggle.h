#import "NUARippleButton.h"

@class NUAFlipswitchToggle;

@protocol NUAFlipswitchToggleDelegate <NSObject>

- (void)toggleWantsNotificationShadeDismissal:(NUAFlipswitchToggle *)toggle;

@end

@interface NUAFlipswitchToggle : NUARippleButton
@property (weak, nonatomic) id<NUAFlipswitchToggleDelegate> delegate;
@property (copy, readonly, nonatomic) NSString *switchIdentifier;
@property (strong, readonly, nonatomic) UILabel *toggleLabel;
@property (getter=isUsingDark, readonly, nonatomic) BOOL usingDark;

@property (getter=isInverted, readonly, nonatomic) BOOL inverted;
@property (strong, readonly, nonatomic) NSURL *settingsURL;
@property (copy, readonly, nonatomic) NSString *displayName;
@property (strong, readonly, nonatomic) UIImage *icon;
@property (strong, readonly, nonatomic) UIImage *selectedIcon;

- (instancetype)initWithSwitchIdentifier:(NSString *)identifier;

@end