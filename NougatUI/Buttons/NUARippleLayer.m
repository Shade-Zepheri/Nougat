// Copyright 2019-present the Material Components for iOS authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// Modifications copyright (C) 2020 Alfonso Gonzalez

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

static inline CGFloat defaultRippleRadius(CGRect rect) {
    return hypot(CGRectGetMidX(rect), CGRectGetMidY(rect)) + NUAExpandRippleBeyondSurface;
}

@implementation NUARippleLayer

#pragma mark - Layout

- (void)setNeedsLayout {
    [super setNeedsLayout];

    [self setPathFromRadii];
    self.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

- (void)setPathFromRadii {
    CGFloat radius = self.maximumRadius > 0 ? self.maximumRadius : defaultRippleRadius(self.bounds);
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