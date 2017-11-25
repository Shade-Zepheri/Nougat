#import "NUAWindow.h"

@implementation NUAWindow

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.windowLevel = UIWindowLevelAlert + 1.0;
        self._secure = YES;

        [self makeKeyAndVisible];
    }

    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitTestView = [super hitTest:point withEvent:event];
    if (hitTestView == self) {
        hitTestView = nil;
    }

    return hitTestView;
}

@end
