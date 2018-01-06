#import <UIKit/UIKit.h>
#import "headers.h"
#import "NUAStatusBar.h"
#import "NUADrawerPanel.h"
#import "NUAWindow.h"

@interface NUADrawerViewController : UIViewController

@property (strong, readonly, nonatomic) UIView *quickTogglesView;
@property (strong, readonly, nonatomic) _UIBackdropView *backdropView;
@property (strong, readonly, nonatomic) NUAStatusBar *statusBar;
@property (strong, readonly, nonatomic) NUADrawerPanel *togglesPanel;
@property (strong, readonly, nonatomic) NUAWindow *window;

- (void)showQuickToggles:(BOOL)dismiss;
- (void)showMainPanel;
- (void)dismissDrawer;

@end
