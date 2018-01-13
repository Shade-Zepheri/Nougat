#import "NUADrawerViewController.h"

@interface NUANotificationShadeController : NSObject

@property (strong, readonly, nonatomic) NUADrawerViewController *viewController;

+ (instancetype)defaultNotifcationShade;

- (void)dismissDrawer:(BOOL)animated;

- (void)showMainToggles;
- (void)showQuickToggles;
- (BOOL)mainTogglesVisible;
@end
