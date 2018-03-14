#import "NUABrightnessModuleController.h"

//TODO: make UIScrollView for more than one page of toggles?
@interface NUADrawerPanel : UIView {
    NUABrightnessModuleController *_brightnessSection;
}

@property (strong, readonly, nonatomic) NSMutableArray *toggleArray;

- (void)refreshTogglePanel;

@end
