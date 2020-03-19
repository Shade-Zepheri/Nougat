#import <UIKit/UIKit.h>

@protocol NUANotificationShadePageContentViewControllerDelegate <NSObject>
@required

- (void)contentViewControllerWantsDismissal:(UIViewController *)contentViewController completely:(BOOL)completely;
- (void)contentViewControllerWantsExpansion:(UIViewController *)contentViewController;
- (CGFloat)contentViewControllerRequestsInteractiveHeight:(UIViewController *)contentViewController;

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