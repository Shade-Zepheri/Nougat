#import "NUATogglesModuleController.h"

@implementation NUATogglesModuleController

- (NSString *)moduleIdentifier {
    return @"com.shade.nougat.toggles";
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

#pragma mark - Content provider

- (void)setPresentedHeight:(CGFloat)height {
    _presentedHeight = height;

    if (height < 150) {
        return;
    }

    // Set new height (don't ask about func, line of best fit / lazy);
    CGFloat newConstant = (0.857143 * height) - 78.571429;
    _heightConstraint.constant = round(newConstant);
}

@end