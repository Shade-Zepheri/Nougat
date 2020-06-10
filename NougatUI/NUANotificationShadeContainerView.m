#import "NUANotificationShadeContainerView.h"

@implementation NUANotificationShadeContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Create blur
        UIBlurEffect *darkeningBlur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _darkeningView = [[UIVisualEffectView alloc] initWithEffect:darkeningBlur];
        _darkeningView.alpha = 0.0;
        _darkeningView.frame = frame;
        _darkeningView.userInteractionEnabled = YES;
        _darkeningView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_darkeningView];

        // Add constraints
        [_darkeningView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [_darkeningView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
        [_darkeningView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
        [_darkeningView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    }

    return self;
}


#pragma mark - Properties

- (void)setPresentedHeight:(CGFloat)height {
    _presentedHeight = height;

    // Change alpha on backdrop (use this little trick to have it be 1 alpha at quick toggles)
    self.darkeningView.alpha = height / 150.0;
}

- (void)setChangingBrightness:(BOOL)changingBrightness {
    _changingBrightness = changingBrightness;

    // Animate view alpha
    [UIView animateWithDuration:0.25 animations:^{
        self.darkeningView.alpha = changingBrightness ? 0.0 : 1.0;
    }];
}

@end
