#import "NUABrightnessModuleController.h"
#import "NUAQuickTogglesSectionController.h"
#import "NUAStatusBarSectionController.h"
#import "NUATogglesSectionController.h"

@interface NUAModulesContainerViewController : UIViewController {
    UIStackView *_verticalStackView;
    NUABrightnessModuleController *_brightnessModule;
    //NUAQuickTogglesSectionController *_quickSection;
    //NUAStatusBarSectionController *_statusBarSection;
    //NUATogglesSectionController *_togglesSection;
}

@end
