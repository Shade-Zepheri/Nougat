#import "NUADrawerViewController.h"

@interface NUADrawerController : NSObject {
    BOOL _quickMenuVisible;
    BOOL _mainPanelVisible;
}
@property (strong, nonatomic) NUADrawerViewController *viewController;
+ (instancetype)sharedInstance;
@end
