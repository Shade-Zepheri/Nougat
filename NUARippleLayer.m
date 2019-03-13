#import "NUARippleLayer.h"

@implementation NUARippleLayer

- (instancetype)init {
    self = [super init];
    if (self) {
        // Set fallback incase not set
        _rippleColor = [UIColor colorWithWhite:0 alpha:0.08];
    }

    return self;
}

#pragma mark - Radius

- (void)setNeedsLayout {
    [super setNeedsLayout];
    [self setRadiiWithRect:self.bounds];
}

- (void)setRadiiWithRect:(CGRect)rect {
    // Calculate radius
    self.initialRadius = hypot(CGRectGetHeight(rect), CGRectGetWidth(rect)) / 2 * 0.6;
    self.finalRadius = hypot(CGRectGetHeight(rect), CGRectGetWidth(rect)) / 2 + 10.0;
}

#pragma mark - Ripple animation

- (void)startRippleAtPoint:(CGPoint)point animated:(BOOL)animated {
    CGFloat radius = self.finalRadius;
    if (self.maxRippleRadius > 0) {
        radius = self.maxRippleRadius;
    }

    CGRect ovalRect = CGRectMake(CGRectGetWidth(self.bounds) / 2 - radius, CGRectGetHeight(self.bounds) / 2 - radius, radius * 2, radius * 2);
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:ovalRect];
    self.path = circlePath.CGPath;
    self.fillColor = self.rippleColor.CGColor;
    if (!animated) {
        self.opacity = 1;
        self.position = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
    } else {
        self.opacity = 0;
        self.position = point;
        _startAnimationActive = YES;

        CAMediaTimingFunction *materialTimingFunction = [CAMediaTimingFunction functionWithControlPoints:0.4:0:0.2:1.0];
        CGFloat scaleStart = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) / 300.0;
        if (scaleStart < 0.2) {
            scaleStart = 0.2;
        } else if (scaleStart > 0.6) {
            scaleStart = 0.6;
        }

        CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnim.fromValue = @(scaleStart);
        scaleAnim.toValue = @1.0;
        scaleAnim.duration = 0.333;
        // scaleAnim.beginTime = 0.083;
        scaleAnim.timingFunction = materialTimingFunction;
        scaleAnim.fillMode = kCAFillModeForwards;
        scaleAnim.removedOnCompletion = NO;

        UIBezierPath *centerPath = [UIBezierPath bezierPath];
        CGPoint startPoint = point;
        CGPoint endPoint = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
        [centerPath moveToPoint:startPoint];
        [centerPath addLineToPoint:endPoint];
        [centerPath closePath];

        CAKeyframeAnimation *positionAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        positionAnim.path = centerPath.CGPath;
        positionAnim.keyTimes = @[ @0, @1.0 ];
        positionAnim.values = @[ @0, @1.0 ];
        positionAnim.duration = 0.333;
        // positionAnim.beginTime = 0.083;
        positionAnim.timingFunction = materialTimingFunction;
        positionAnim.fillMode = kCAFillModeForwards;
        positionAnim.removedOnCompletion = NO;

        CABasicAnimation *fadeInAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeInAnim.fromValue = @0;
        fadeInAnim.toValue = @1.0;
        fadeInAnim.duration = 0.083;
        // fadeInAnim.beginTime = 0.083;
        fadeInAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        fadeInAnim.fillMode = kCAFillModeForwards;
        fadeInAnim.removedOnCompletion = NO;

        [CATransaction begin];
        CAAnimationGroup *animGroup = [CAAnimationGroup animation];
        animGroup.animations = @[ scaleAnim, positionAnim, fadeInAnim ];
        animGroup.duration = 0.333;
        animGroup.fillMode = kCAFillModeForwards;
        animGroup.removedOnCompletion = NO;
        [CATransaction setCompletionBlock:^{
            self->_startAnimationActive = NO;
        }];
        [self addAnimation:animGroup forKey:nil];
        [CATransaction commit];
    }
}

- (void)endRippleAtPoint:(CGPoint)point animated:(BOOL)animated {
    if (self.startAnimationActive) {
        self.endAnimationDelay = 0.25;
    }

    CGFloat opacity = CGRectContainsPoint(self.bounds, point) ? 1.0 : 0.0;
    if (!animated) {
        self.opacity = 0;
        [self removeFromSuperlayer];
    } else {
        [CATransaction begin];
        CABasicAnimation *fadeOutAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeOutAnim.fromValue = @(opacity);
        fadeOutAnim.toValue = @0;
        fadeOutAnim.duration = 0.15;
        fadeOutAnim.beginTime = [self convertTime:(CACurrentMediaTime() + self.endAnimationDelay) fromLayer:nil];
        fadeOutAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        fadeOutAnim.fillMode = kCAFillModeForwards;
        fadeOutAnim.removedOnCompletion = NO;
        [CATransaction setCompletionBlock:^{
            [self removeFromSuperlayer];
        }];
        [self addAnimation:fadeOutAnim forKey:nil];
        [CATransaction commit];
    }
}

@end