#import "NUADrawerViewController.h"

@interface NUADrawerController : NSObject

@property (strong, readonly, nonatomic) NUADrawerViewController *viewController;

+ (instancetype)sharedInstance;

- (void)dismissDrawer;
- (void)showMainToggles;
- (void)showQuickToggles;
- (BOOL)mainTogglesVisible;
@end
