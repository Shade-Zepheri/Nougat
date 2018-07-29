#import "NUATogglesModuleController.h"
#import "NUAFlipswitchToggle.h"
#import "NUAPreferenceManager.h"
#import "NUATogglesContentView.h"
#import <HBLog.h>

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

    // Register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundColorDidChange:) name:@"NUANotificationShadeChangedBackgroundColor" object:nil];

/*
    NSInteger row = 0;
    NSInteger column = 0;

    for (int i = 0; i < 9; i++) {
        NSString *identifier = [NUAPreferenceManager sharedSettings].togglesList[i];
        // 101.667, 116.667 CGRectMake(101.667 * i + 35, 0, 101.667, 116.667)
        // 62.5, 50 CGRectMake(62.5 * i, 0, 62.5, 50)
        if (i % 3 == 0 && i != 0) {
            column = 0;
            row++;
        }

        CGFloat x = 101.667 * column + 35;
        CGFloat y = 101.667 * row;

        column++;

        NUAFlipswitchToggle *toggle = [[NUAFlipswitchToggle alloc] initWithFrame:CGRectMake(x, y, 101.667, 116.667) andSwitchIdentifier:identifier];
        [self.view addSubview:toggle];
    }
*/
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

    HBLogDebug(@"presented height: %f", height);

    if (height == 0.0) {
        // Reset on 0.0;
        height = 150.0;
    } else if (height < 150) {
        // Dont do anything if in first stage
        return;
    }

    // height: 150-500 3 - 10
    // vh: 50-350

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