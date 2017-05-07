#import <UIKit/UIKit.h>

@interface NUADrawerViewController : UIViewController {
  NSArray *_testArray;
}
@property (strong, nonatomic) UIView *statusBar;
@property (strong, nonatomic) UIView *quickTogglesView;
//@property (strong, nonatomic) NUADrawerPanel *togglesPanel;
- (void)showQuickToggles:(BOOL)dismiss;
- (void)showMainPanel;
@end
