#import <UIKit/UIKit.h>
#import "NUANotificationShadePageContentProvider.h"
#import "NUANotificationShadePanelView.h"
#import "NUASystemServicesProvider.h"

@class NUANotificationShadePageContainerViewController;

@protocol NUANotificationShadePageContainerViewControllerDelegate <NSObject>
@property (strong, readonly, nonatomic) NUAPreferenceManager *notificationShadePreferences;
@property (strong, readonly, nonatomic) id<NUASystemServicesProvider> systemServicesProvider;
@required

- (void)containerViewControllerWantsDismissal:(NUANotificationShadePageContainerViewController *)containerViewController;
- (void)containerViewController:(NUANotificationShadePageContainerViewController *)containerViewController updatedPresentedHeight:(CGFloat)presentedHeight;
- (void)containerViewController:(NUANotificationShadePageContainerViewController *)containerViewController updatedRevealPercentage:(CGFloat)revealPercentage;
- (NUAPreferenceManager *)notificationShadePreferences;
- (id<NUASystemServicesProvider>)systemServicesProvider;

@end

typedef NS_ENUM(NSUInteger, NUANotificationShadePanelState) {
    NUANotificationShadePanelStateCollapsed,
    NUANotificationShadePanelStateExpanded
};

@interface NUANotificationShadePageContainerViewController : UIViewController <NUANotificationShadePageContentViewControllerDelegate, UIGestureRecognizerDelegate> {
    CGFloat _initialHeight;
}
@property (strong, readonly, nonatomic) NUAPreferenceManager *notificationShadePreferences;
@property (strong, readonly, nonatomic) id<NUASystemServicesProvider> systemServicesProvider;
@property (weak, nonatomic) id<NUANotificationShadePageContainerViewControllerDelegate> delegate;
@property (readonly, nonatomic) UIViewController<NUANotificationShadePageContentProvider> *contentViewController;
@property (strong, readonly, nonatomic) UIPanGestureRecognizer *panGesture;
@property (assign, nonatomic) CGFloat presentedHeight;
@property (assign, nonatomic) CGFloat revealPercentage;
@property (assign, readonly, nonatomic) CGFloat contentPresentedHeight;
@property (readonly, nonatomic) NUANotificationShadePanelState panelState;

- (instancetype)initWithContentViewController:(UIViewController<NUANotificationShadePageContentProvider> *)viewController andDelegate:(id<NUANotificationShadePageContainerViewControllerDelegate>)delegate;

- (NUANotificationShadePanelView *)_panelView;

- (void)updateToFinalPresentedHeight:(CGFloat)finalHeight completion:(void(^)(void))completion;
- (void)handleDismiss:(BOOL)animated completion:(void(^)(void))completion;

@end