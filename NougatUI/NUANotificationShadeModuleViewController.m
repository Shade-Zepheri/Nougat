#import "NUANotificationShadeModuleViewController.h"

@implementation NUANotificationShadeModuleViewController

+ (Class)viewClass {
    return UIView.class;
}

- (void)loadView {
    UIView *view = [[[self.class viewClass] alloc] initWithFrame:CGRectZero];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.view = view;

    _heightConstraint = [view.heightAnchor constraintEqualToConstant:50.0];
    _heightConstraint.active = YES;
}

- (NSString *)moduleIdentifier {
    return @"";
}

#pragma mark - UIViewController

- (BOOL)_canShowWhileLocked {
    // New on iOS 13
    return YES;
}

@end