#import <UIKit/UIKit.h>
#import "NUANotificationShadePageContentProvider.h"
#import "NUANotificationShadePanelView.h"

@class NUANotificationShadePageContainerViewController;

@protocol NUANotificationShadePageContainerViewControllerDelegate <NSObject>
@required

- (void)containerViewControllerWantsDismissal:(NUANotificationShadePageContainerViewController *)containerViewController;
- (CGFloat)containerViewControllerRequestsInteractiveHeight:(NUANotificationShadePageContainerViewController *)containerViewController;
- (void)containerViewController:(NUANotificationShadePageContainerViewController *)containerViewController updatedPresentedHeight:(CGFloat)presentedHeight;

@end

typedef NS_ENUM(NSUInteger, NUANotificationShadePanelState) {
    NUANotificationShadePanelStateCollapsed,
    NUANotificationShadePanelStateExpanded
};

@interface NUANotificationShadePageContainerViewController : UIViewController <NUANotificationShadePageContentViewControllerDelegate, UIGestureRecognizerDelegate> {
    CGFloat _initialHeight;
}
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
- (void)handleDismiss;

@end