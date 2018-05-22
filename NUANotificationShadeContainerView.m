#import "NUANotificationShadeContainerView.h"
#import "Macros.h"
#import <UIKit/_UIBackdropViewSettings.h>

@implementation NUANotificationShadeContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Create backdrop view
        _UIBackdropViewSettings *blurSettings = [_UIBackdropViewSettings settingsForStyle:2030 graphicsQuality:100];
        _backdropView = [[NSClassFromString(@"_UIBackdropView") alloc] initWithFrame:frame autosizesToFitSuperview:NO settings:blurSettings];
        _backdropView.userInteractionEnabled = YES;
        _backdropView.alpha = 0;
        [self addSubview:_backdropView];
    }

    return self;
}

- (void)setPresentedHeight:(CGFloat)height {
    _presentedHeight = height;

    // Change alpha on backdrop (use this little trick to have it be 1 alpha at quick toggles)
    _backdropView.alpha = height / (kScreenHeight / 5);

    // Force relayout of the subviews (private methods)
    [self setNeedsLayout];
    [self layoutBelowIfNeeded];
}

- (void)setChangingBrightness:(BOOL)changingBrightness {
    _changingBrightness = changingBrightness;

    // Animate view alpha
    [UIView animateWithDuration:0.25 animations:^{
        _backdropView.alpha = changingBrightness ? 1.0 : 0.0;
    }];
}

- (void)layoutSubviews {
    [self _updateContentViewMasks];
}

- (void)_updateContentViewMasks {
    // Heres where the magic happens

    // TODO: figure out the voodoo that goes on
    // Update frames
    UIView *drawerView = [self.delegate notificationShadeForContainerView:self];
    drawerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), self.presentedHeight);
}

@end
