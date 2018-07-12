#import <UIKit/UIKit.h>
#import "NUANotificationShadePageContentProvider.h"
#import "NUAStatusBarModuleController.h"
#import "NUABrightnessModuleController.h"
#import "NUATogglesModuleController.h"
#import "NUASettingsModuleController.h"

@interface NUAModulesContainerViewController : UIViewController <NUANotificationShadePageContentProvider> {
    NSMutableArray<NUANotificationShadeModuleViewController *> *_moduleList;
    UIStackView *_verticalStackView;
    NUAStatusBarModuleController *_statusBarModule;
    NUABrightnessModuleController *_brightnessModule;
    NUATogglesModuleController *_togglesModule;
    NUASettingsModuleController *_settingsModule;
}

@property (assign, nonatomic) CGFloat presentedHeight;

@end
