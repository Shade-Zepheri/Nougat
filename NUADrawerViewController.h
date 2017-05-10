#import <UIKit/UIKit.h>
#import "NUAStatusBar.h"
#import "NUADrawerPanel.h"

@interface NUADrawerViewController : UIViewController {
  NSArray *_testArray;
}
@property (strong, nonatomic) UIView *quickTogglesView;
@property (strong, nonatomic) NUAStatusBar *statusBar;
@property (strong, nonatomic) NUADrawerPanel *togglesPanel;
- (void)showQuickToggles:(BOOL)dismiss;
- (void)showMainPanel;
@end
