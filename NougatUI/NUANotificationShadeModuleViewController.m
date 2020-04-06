#import "NUANotificationShadeModuleViewController.h"

@implementation NUANotificationShadeModuleViewController

#pragma mark - NUANotificationShadeModuleViewController

+ (Class)viewClass {
    return UIView.class;
}

+ (CGFloat)defaultModuleHeight {
    return 50.0;
}

- (NSString *)moduleIdentifier {
    return @"";
}

#pragma mark - UIViewController

- (void)loadView {
    UIView *view = [[[self.class viewClass] alloc] initWithFrame:CGRectZero];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.view = view;

    CGFloat defaultModuleHeight = [self.class defaultHeight];
    _heightConstraint = [view.heightAnchor constraintEqualToConstant:defaultModuleHeight];
    _heightConstraint.active = YES;
}

- (BOOL)_canShowWhileLocked {
    // New on iOS 13
    return YES;
}

@end