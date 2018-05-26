#import <UIKit/UIKit.h>
#import "NUANotificationShadePageContentProvider.h"
#import "NUABrightnessModuleController.h"
#import "NUAStatusBarSectionController.h"
#import "NUATogglesSectionController.h"

@interface NUAModulesContainerViewController : UIViewController <NUANotificationShadePageContentProvider> {
    UIStackView *_verticalStackView;
    NUABrightnessModuleController *_brightnessModule;
    //NUAStatusBarSectionController *_statusBarSection;
    //NUATogglesSectionController *_togglesSection;
}

@property (nonatomic) CGFloat presentedHeight;

@end
