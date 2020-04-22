#import "NUARippleLayer.h"
#import <math.h>

// Our lovely constants
static const CGFloat NUAExpandRippleBeyondSurface = 10;
static const CGFloat NUARippleStartingScale = 0.6;
static const NSTimeInterval NUARippleTouchDownDuration = 0.4;
static const NSTimeInterval NUARippleTouchUpDuration = 0.15;
static const NSTimeInterval NUARippleFadeInDuration = 0.083;
static const NSTimeInterval NUARippleFadeOutDuration = 0.075;
static const NSTimeInterval NUARippleFadeOutDelay = 0.15;

static NSString *const NUARippleLayerOpacityAnimationString = @"opacity";
static NSString *const NUARippleLayerPositionAnimationString = @"position";
static NSString *const NUARippleLayerScaleAnimationString = @"transform.scale";

@implementation NUARippleLayer

#pragma mark - Layout

- (void)setNeedsLayout {
    [super setNeedsLayout];

    [self setPathFromRadii];
    self.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

- (void)setPathFromRadii {
    CGFloat radius = hypot(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)) + NUAExpandRippleBeyondSurface;
    CGRect ovalRect = CGRectMake(CGRectGetMidX(self.bounds) - radius, CGRectGetMidY(self.bounds) - radius, radius * 2, radius * 2);
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:ovalRect];
    self.path = circlePath.CGPath;
}

#pragma mark - Ripple

- (void)startRippleAtPoint:(CGPoint)point animated:(BOOL)animated {
    [self setPathFromRadii];
    self.opacity = 1;
    self.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    if (!animated) {
        // Nothing to do
        return;
    } 
    _startAnimationActive = YES;

    CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:NUARippleLayerScaleAnimationString];
    scaleAnim.fromValue = @(NUARippleStartingScale);
    scaleAnim.toValue = @(1);
    scaleAnim.timingFunction = [[CAMediaTimingFunction alloc] initWithControlPoints:0.4:0:0.2:1];

    UIBezierPath *centerPath = [UIBezierPath bezierPath];
    CGPoint startPoint = point;
    CGPoint endPoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [centerPath moveToPoint:startPoint];
    [centerPath addLineToPoint:endPoint];
    [centerPath closePath];

    CAKeyframeAnimation *positionAnim = [CAKeyframeAnimation animationWithKeyPath:NUARippleLayerPositionAnimationString];
    positionAnim.path = centerPath.CGPath;
    positionAnim.keyTimes = @[@(0), @(1)];
    positionAnim.values = @[@(0), @(1)];
    positionAnim.timingFunction = [[CAMediaTimingFunction alloc] initWithControlPoints:0.4:0:0.2:1];

    CABasicAnimation *fadeInAnim = [CABasicAnimation animationWithKeyPath:NUARippleLayerOpacityAnimationString];
    fadeInAnim.fromValue = @(0);
    fadeInAnim.toValue = @(1);
    fadeInAnim.duration = NUARippleFadeInDuration;
    fadeInAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];

    [CATransaction begin];
    CAAnimationGroup *animGroup = [[CAAnimationGroup alloc] init];
    animGroup.animations = @[scaleAnim, positionAnim, fadeInAnim];
    animGroup.duration = NUARippleTouchDownDuration;
    [CATransaction setCompletionBlock:^{
        self->_startAnimationActive = NO;
    }];
    [self addAnimation:animGroup forKey:nil];
    _rippleTouchDownStartTime = CACurrentMediaTime();
    [CATransaction commit];
}

- (void)endRippleAnimated:(BOOL)animated completion:(NUARippleCompletionBlock)completion {
    CGFloat delay = 0;
    if (self.startAnimationActive) {
        delay = NUARippleFadeOutDelay;
    }

    [CATransaction begin];
    CABasicAnimation *fadeOutAnim = [CABasicAnimation animationWithKeyPath:NUARippleLayerOpacityAnimationString];
    fadeOutAnim.fromValue = @(1);
    fadeOutAnim.toValue = @(0);
    fadeOutAnim.duration = animated ? NUARippleTouchUpDuration : 0;
    fadeOutAnim.beginTime = [self convertTime:_rippleTouchDownStartTime + delay fromLayer:nil];
    fadeOutAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    fadeOutAnim.fillMode = kCAFillModeForwards;
    fadeOutAnim.removedOnCompletion = NO;
    [CATransaction setCompletionBlock:^{
        if (completion) {
            completion();
        }

        [self removeFromSuperlayer];
    }];
    [self addAnimation:fadeOutAnim forKey:nil];
    [CATransaction commit];
}

- (void)fadeInRippleAnimated:(BOOL)animated {
    [CATransaction begin];
    CABasicAnimation *fadeInAnim = [CABasicAnimation animationWithKeyPath:NUARippleLayerOpacityAnimationString];
    fadeInAnim.fromValue = @(0);
    fadeInAnim.toValue = @(1);
    fadeInAnim.duration = animated ? NUARippleFadeInDuration : 0;
    fadeInAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    fadeInAnim.fillMode = kCAFillModeForwards;
    fadeInAnim.removedOnCompletion = NO;
    [self addAnimation:fadeInAnim forKey:nil];
    [CATransaction commit];
}

- (void)fadeOutRippleAnimated:(BOOL)animated {
    [CATransaction begin];
    CABasicAnimation *fadeInAnim = [CABasicAnimation animationWithKeyPath:NUARippleLayerOpacityAnimationString];
    fadeInAnim.fromValue = @(1);
    fadeInAnim.toValue = @(0);
    fadeInAnim.duration = animated ? NUARippleFadeOutDuration : 0;
    fadeInAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    fadeInAnim.fillMode = kCAFillModeForwards;
    fadeInAnim.removedOnCompletion = NO;
    [self addAnimation:fadeInAnim forKey:nil];
    [CATransaction commit];
}

@end