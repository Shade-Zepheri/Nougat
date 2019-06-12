#import "NUANotificationShadeContainerView.h"
#import <UIKit/_UIBackdropViewSettings+Private.h>

@implementation NUANotificationShadeContainerView

- (instancetype)initWithFrame:(CGRect)frame andDelegate:(id<NUANotificationShadeContainerViewDelegate>)delegate {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = delegate;

        // Create blur
        UIBlurEffect *darkeningBlur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _darkeningView = [[UIVisualEffectView alloc] initWithEffect:darkeningBlur];
        self.darkeningView.alpha = 0.0;
        self.darkeningView.frame = frame;
        self.darkeningView.userInteractionEnabled = YES;
        self.darkeningView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.darkeningView];

        // Add constraints
        [self.darkeningView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [self.darkeningView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
        [self.darkeningView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
        [self.darkeningView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    }

    return self;
}

#pragma mark - View management

- (void)layoutSubviews {
    [super layoutSubviews];

    NUANotificationShadePanelView *panelView = [self.delegate notificationPanelForContainerView:self];
    panelView.height = self.presentedHeight;
}

#pragma mark - Properties

- (void)setPresentedHeight:(CGFloat)height {
    _presentedHeight = height;

    // Update panel view
    NUANotificationShadePanelView *panelView = [self.delegate notificationPanelForContainerView:self];
    panelView.height = height;

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
