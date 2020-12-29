#import <UIKit/UIKit.h>
#import "NUASystemServicesProvider.h"
#import <NougatServices/NougatServices.h>

@protocol NUANotificationShadePageContentViewControllerDelegate <NSObject>
@property (strong, readonly, nonatomic) NUAPreferenceManager *notificationShadePreferences;
@property (strong, readonly, nonatomic) id<NUASystemServicesProvider> systemServicesProvider;
@required

- (void)contentViewControllerWantsDismissal:(UIViewController *)contentViewController completely:(BOOL)completely;
- (void)contentViewControllerWantsExpansion:(UIViewController *)contentViewController;
- (NUAPreferenceManager *)notificationShadePreferences;
- (id<NUASystemServicesProvider>)systemServicesProvider;

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