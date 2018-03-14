// Would use the one included in theos but it causes compilation errors

@interface UIWindow (Private)

+ (UIWindow *)keyWindow;

@property (getter=_isSecure, setter=_setSecure:) BOOL _secure;

- (void)_setRotatableViewOrientation:(UIInterfaceOrientation)orientation updateStatusBar:(BOOL)updateStatusBar duration:(CGFloat)duration force:(BOOL)force;

@end
