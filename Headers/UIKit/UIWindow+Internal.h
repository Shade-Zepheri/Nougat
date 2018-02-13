// Would use the one included in theos but it causes compilation errors

@interface UIWindow (Private)

+ (UIWindow *)keyWindow;

@property (getter=_isSecure, setter=_setSecure:) BOOL _secure;

@end
