#import "NUATogglesModuleController.h"
#import "NUAFlipswitchToggle.h"
#import "NUAPreferenceManager.h"
#import "NUATogglesContentView.h"

@implementation NUATogglesModuleController

+ (Class)viewClass {
    return NUATogglesContentView.class;
}

- (NSString *)moduleIdentifier {
    return @"com.shade.nougat.toggles";
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Figure out what else to do here

    // Register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundColorDidChange:) name:@"NUANotificationShadeChangedBackgroundColor" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [[self _togglesContentView] _layoutToggles];
}

- (NUATogglesContentView *)_togglesContentView {
    return (NUATogglesContentView *)self.view;
}

#pragma mark - Properties

- (void)setPresentedHeight:(CGFloat)height {
    _presentedHeight = height;

    if (height == 0.0) {
        // Reset on 0.0;
        height = 150.0;
    } else if (height < 150) {
        // Dont do anything if in first stage
        return;
    }

    // Set new height (don't ask about func, line of best fit / lazy);
    CGFloat multiplier = height - 150.0;
    CGFloat newConstant = (0.857143 * multiplier) + 50;
    _heightConstraint.constant = newConstant;

    // Pass to view
    [self _togglesContentView].expandedPercent = multiplier / 350;
}

#pragma mark - Notifications

- (void)backgroundColorDidChange:(NSNotification *)notification {
    // Defer to view
    [[self _togglesContentView] _updateToggleIdentifiers];
}

@end