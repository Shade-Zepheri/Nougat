#import <UIKit/UIKit.h>
#import "NUANotificationShadePageContentProvider.h"
#import "NUANotificationShadePanelView.h"

@interface NUANotificationShadePageContainerViewController : UIViewController
@property (readonly, nonatomic) UIViewController<NUANotificationShadePageContentProvider> *contentViewController;
@property (nonatomic) CGFloat presentedHeight;

- (instancetype)initWithContentViewController:(UIViewController<NUANotificationShadePageContentProvider> *)viewController;

- (NUANotificationShadePanelView *)_panelView;

@end