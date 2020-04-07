#import <UIKit/UIKit.h>
#import <NougatServices/NougatServices.h>

@protocol NUANotificationShadePageContentViewControllerDelegate <NSObject>
@property (strong, readonly, nonatomic) NUAPreferenceManager *notificationShadePreferences;
@required

- (void)contentViewControllerWantsDismissal:(UIViewController *)contentViewController completely:(BOOL)completely;
- (void)contentViewControllerWantsExpansion:(UIViewController *)contentViewController;
- (NUAPreferenceManager *)notificationShadePreferences;

@end

@protocol NUANotificationShadePageContentProvider <NSObject>
@property (weak, nonatomic) id<NUANotificationShadePageContentViewControllerDelegate> delegate;
@property (assign, nonatomic) CGFloat revealPercentage;
@property (readonly, nonatomic) CGFloat fullyPresentedHeight;

@required
- (void)setRevealPercentage:(CGFloat)height;
- (CGFloat)revealPercentage;

- (CGFloat)fullyPresentedHeight;

- (void)setDelegate:(id<NUANotificationShadePageContentViewControllerDelegate>)delegate;
- (id<NUANotificationShadePageContentViewControllerDelegate>)delegate;

@end