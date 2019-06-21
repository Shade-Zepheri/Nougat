#import <UIKit/UIKit.h>
#import "NUANotificationShadePageContentProvider.h"
#import "NUANotificationShadePanelView.h"

@class NUANotificationShadePageContainerViewController;

@protocol NUANotificationShadePageContainerViewControllerDelegate <NSObject>
@required

- (void)containerViewControllerWantsDismissal:(NUANotificationShadePageContainerViewController *)containerViewController completely:(BOOL)completely;
- (void)containerViewControllerWantsExpansion:(NUANotificationShadePageContainerViewController *)containerViewController;
- (CGFloat)containerViewControllerFullyPresentedHeight:(NUANotificationShadePageContainerViewController *)containerViewController;

@end

@interface NUANotificationShadePageContainerViewController : UIViewController <NUANotificationShadePageContentViewControllerDelegate, UIGestureRecognizerDelegate> {
    CGFloat _initialHeight;
}
@property (weak, nonatomic) id<NUANotificationShadePageContainerViewControllerDelegate> delegate;
@property (readonly, nonatomic) UIViewController<NUANotificationShadePageContentProvider> *contentViewController;
@property (strong, readonly, nonatomic) UIPanGestureRecognizer *panGesture;
@property (assign, nonatomic) CGFloat presentedHeight;
@property (assign, nonatomic) CGFloat revealPercentage;

- (instancetype)initWithContentViewController:(UIViewController<NUANotificationShadePageContentProvider> *)viewController andDelegate:(id<NUANotificationShadePageContainerViewControllerDelegate>)delegate;

- (NUANotificationShadePanelView *)_panelView;

@end