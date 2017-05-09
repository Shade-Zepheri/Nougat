#import <UIKit/UIKit.h>
#import "NUAStatusBar.h"

@interface NUADrawerViewController : UIViewController {
  NSArray *_testArray;
}
@property (strong, nonatomic) UIView *quickTogglesView;
@property (strong, nonatomic) NUAStatusBar *statusBar;
- (void)showQuickToggles:(BOOL)dismiss;
- (void)showMainPanel;
@end
