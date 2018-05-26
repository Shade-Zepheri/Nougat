#import "NUAModulesContainerViewController.h"
#import "NUANotificationShadePanelView.h"

@implementation NUAModulesContainerViewController

#pragma mark - View management

- (void)loadView {
    [super loadView];
    // Create stackview

    // Load modules
    _brightnessModule = [[NUABrightnessModuleController alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {

}

#pragma mark - Delegate

- (void)setPresentedHeight:(CGFloat)height {
    // TODO: Use to expand to be "Expandable collection view"
    _presentedHeight = height;
}

@end
