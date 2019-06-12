#import "NUANotificationShadeContainerView.h"
#import <UIKit/_UIBackdropViewSettings+Private.h>

@implementation NUANotificationShadeContainerView

- (instancetype)initWithFrame:(CGRect)frame andDelegate:(id<NUANotificationShadeContainerViewDelegate>)delegate {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = delegate;

        UIBlurEffect *darkeningBlur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _darkeningView = [[UIVisualEffectView alloc] initWithEffect:darkeningBlur];
        self.darkeningView.frame = frame;
        self.darkeningView.userInteractionEnabled = YES;
        self.darkeningView.alpha = 0.0;
        [self addSubview:self.darkeningView];

        [self _updateMasks];
    }

    return self;
}

#pragma mark - Properties

- (void)setPresentedHeight:(CGFloat)height {
    _presentedHeight = height;

    // Force relayout of the subviews (private methods)
    [self setNeedsLayout];
    [self layoutBelowIfNeeded];

    if (height > 151.0) {
        // No need to change alpha further
        return;
    }
    // Change alpha on backdrop (use this little trick to have it be 1 alpha at quick toggles)
    _backdropView.alpha = height / 150.0;
}

- (void)setChangingBrightness:(BOOL)changingBrightness {
    _changingBrightness = changingBrightness;

    // Animate view alpha
    [UIView animateWithDuration:0.25 animations:^{
        _backdropView.alpha = changingBrightness ? 0.0 : 1.0;
    }];
}

#pragma mark - View management

- (void)layoutSubviews {
    [self _updateContentFrame];
    [self _updateMasks];
}

- (void)_updateContentFrame {
    _backdropView.frame = self.bounds;
}

- (void)_updateMasks {
    // Defer expansion to view
    NUANotificationShadePanelView *panelView = [self.delegate notificationPanelForContainerView:self];
    [panelView expandHeight:self.presentedHeight];
}

@end
