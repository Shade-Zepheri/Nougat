#import "NUATogglesModuleController.h"

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

    // Set as delegate
    [self _togglesContentView].delegate = self;

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

    CGFloat fullHeight = [self.delegate moduleWantsNotificationShadeFullyPresentedHeight:self];

    if (height == 0.0) {
        // Reset on 0.0;
        height = 150.0;
    } else if (height < 150) {
        // Dont do anything if in first stage
        return;
    }

    // Set new height (don't ask about func, line of best fit / lazy);
    CGFloat expandedHeight = height - 150.0;
    CGFloat totalHeight = fullHeight - 200;
    CGFloat percent = expandedHeight / (fullHeight - 150);
    CGFloat newConstant = percent * totalHeight + 50;
    _heightConstraint.constant = newConstant;

    // Pass to view
    [self _togglesContentView].expandedPercent = percent;
}

#pragma mark - Delegate

- (void)contentViewWantsNotificationShadeDismissal:(NUATogglesContentView *)contentView {
    [self.delegate moduleWantsNotificationShadeDismissal:self completely:YES];
}

#pragma mark - Notifications

- (void)backgroundColorDidChange:(NSNotification *)notification {
    // Defer to view
    [[self _togglesContentView] refreshToggleLayout];
}

@end