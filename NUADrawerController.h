#import "NUADrawerViewController.h"

@interface NUADrawerController : NSObject {
    BOOL _quickMenuVisible;
    BOOL _mainPanelVisible;
}
@property (nonatomic, strong) NUADrawerViewController *viewController;

+ (instancetype)sharedInstance;
@end
