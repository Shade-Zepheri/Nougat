#import "NUADrawerViewController.h"

@interface NUADrawerController : NSObject

@property (strong, readonly, nonatomic) NUADrawerViewController *viewController;

+ (instancetype)sharedInstance;

- (void)dismissDrawer:(BOOL)animated;

- (void)showMainToggles;
- (void)showQuickToggles;
- (BOOL)mainTogglesVisible;
@end
