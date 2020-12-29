#import <UIKit/UIKit.h>
#import "NUAMainTableViewController.h"
#import "NUANotificationShadeContainerView.h"
#import "NUANotificationShadePageContainerViewController.h"

@class NUANotificationShadeViewController;

@protocol NUANotificationShadeViewControllerDelegate <NSObject>
@required

- (void)notificationShadeViewControllerWantsDismissal:(NUANotificationShadeViewController *)controller;
- (void)notificationShadeViewController:(NUANotificationShadeViewController *)controller handlePan:(UIPanGestureRecognizer *)panGestureRecognizer;
- (void)notificationShadeViewController:(NUANotificationShadeViewController *)controller handleTap:(UITapGestureRecognizer *)tapGestureRecognizer;
- (BOOL)notificationShadeViewController:(NUANotificationShadeViewController *)controller canHandleGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;
- (NUAPreferenceManager *)preferencesForNotificationShadeViewController:(NUANotificationShadeViewController *)notificationShadeViewController;

@end

@interface NUANotificationShadeViewController : UIViewController <NUANotificationShadePageContainerViewControllerDelegate, NUAMainTableViewControllerDelegate, UIGestureRecognizerDelegate> {
    NUANotificationShadePageContainerViewController *_containerViewController;
    NUANotificationShadeContainerView *_containerView;
    UIPanGestureRecognizer *_panGesture;
    UITapGestureRecognizer *_tapGesture;
}
@property (strong, readonly, nonatomic) NUAPreferenceManager *notificationShadePreferences;
@property (strong, readonly, nonatomic) id<NUASystemServicesProvider> systemServicesProvider;
@property (strong, readonly, nonatomic) NUAMainTableViewController *tableViewController;
@property (weak, nonatomic) id<NUANotificationShadeViewControllerDelegate> delegate;
@property (assign, nonatomic) CGFloat presentedHeight;
@property (assign, readonly, nonatomic) CGFloat fullyPresentedHeight;

+ (void)notifyNotificationShade:(NSString *)message didActivate:(BOOL)activated;

- (instancetype)initWithSystemServicesProvider:(id<NUASystemServicesProvider>)systemServicesProvider;

- (void)dismissAnimated:(BOOL)animated completion:(void(^)(void))completion;
- (void)updateToFinalPresentedHeight:(CGFloat)finalHeight completion:(void(^)(void))completion;

@end
