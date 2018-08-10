#import "NUANotificationShadeContainerView.h"
#import "Macros.h"
#import <UIKit/_UIBackdropViewSettings+Private.h>

@implementation NUANotificationShadeContainerView

- (instancetype)initWithFrame:(CGRect)frame andDelegate:(id<NUANotificationShadeContainerViewDelegate>)delegate {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = delegate;

        // Create backdrop view
        _UIBackdropViewSettings *blurSettings = [_UIBackdropViewSettings settingsForStyle:2030 graphicsQuality:100];
        _backdropView = [[NSClassFromString(@"_UIBackdropView") alloc] initWithFrame:frame autosizesToFitSuperview:NO settings:blurSettings];
        _backdropView.userInteractionEnabled = YES;
        _backdropView.alpha = 0;
        [self addSubview:_backdropView];

        [self _updateMasks];
    }

    return self;
}

- (void)setPresentedHeight:(CGFloat)height {
    _presentedHeight = height;

    // Change alpha on backdrop (use this little trick to have it be 1 alpha at quick toggles)
    _backdropView.alpha = height / 150;

    // Force relayout of the subviews (private methods)
    [self setNeedsLayout];
    [self layoutBelowIfNeeded];
}

- (void)setChangingBrightness:(BOOL)changingBrightness {
    _changingBrightness = changingBrightness;

    // Animate view alpha
    [UIView animateWithDuration:0.25 animations:^{
        _backdropView.alpha = changingBrightness ? 0.0 : 1.0;
    }];
}

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
