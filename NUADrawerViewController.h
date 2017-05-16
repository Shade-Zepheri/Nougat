#import <UIKit/UIKit.h>
#import "headers.h"
#import "NUAStatusBar.h"
#import "NUADrawerPanel.h"

@interface NUADrawerViewController : UIViewController
@property (strong, nonatomic) UIView *quickTogglesView;
@property (strong, nonatomic) _UIBackdropView *backdropView;
@property (strong, nonatomic) NUAStatusBar *statusBar;
@property (strong, nonatomic) NUADrawerPanel *togglesPanel;
- (void)showQuickToggles:(BOOL)dismiss;
- (void)showMainPanel;
- (void)dismissDrawer;
@end
