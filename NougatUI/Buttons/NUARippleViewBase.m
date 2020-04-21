#import "NUARippleViewBase.h"
#import "NUARippleLayer.h"

@interface NUARippleViewBase () <CALayerDelegate>
@property (strong, nonatomic) NUARippleLayer *activeRippleLayer;
@property (strong, nonatomic) CAShapeLayer *maskLayer;

@end

@interface NUARipplePendingAnimation : NSObject <CAAction>
@property(weak, nonatomic) CALayer *animationSourceLayer;
@property(copy, nonatomic) NSString *keyPath;
@property(strong, nonatomic) id fromValue;
@property(strong, nonatomic) id toValue;

@end

static const CGFloat NUARippleDefaultAlpha = 0.16;
static const CGFloat NUARippleFadeOutDelay = 0.15;

@implementation NUARippleViewBase

@synthesize activeRippleLayer = _activeRippleLayer;

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Setup defaults
        self.userInteractionEnabled = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

        // Create only once
        static UIColor *defaultRippleColor;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            defaultRippleColor = [[UIColor alloc] initWithWhite:0 alpha:NUARippleDefaultAlpha];
        });
        _rippleColor = defaultRippleColor;
        _rippleStyle = NUARippleStyleBounded;
    }

    return self;
}

#pragma mark - View Management

- (void)layoutSubviews {
    [super layoutSubviews];

    // Update fill color
    self.activeRippleLayer.fillColor = self.activeRippleColor.CGColor;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];

    // Update styling
    NSArray<CALayer *> *sublayers = self.layer.sublayers;
    if (sublayers.count > 0) {
        [self updateRippleStyle];
    }

    for (CALayer *sublayer in sublayers) {
        sublayer.frame = CGRectStandardize(self.bounds);
        [sublayer setNeedsLayout];
    }
}

#pragma mark - Properties

- (void)setRippleStyle:(NUARippleStyle)rippleStyle {
    if (rippleStyle == _rippleStyle) {
        // Same thing
        return;
    }

    // Update styling
    _rippleStyle = rippleStyle;
    [self updateRippleStyle];
}

- (NUARippleLayer *)activeRippleLayer {
    return (self.layer.sublayers.count < 1) ? nil : _activeRippleLayer;
}

- (void)setActiveRippleLayer:(NUARippleLayer *)activeRippleLayer {
    _activeRippleLayer = activeRippleLayer;

    // Update color
    self.activeRippleColor = self.rippleColor;
}

- (void)setActiveRippleColor:(UIColor *)activeRippleColor {
    if ([activeRippleColor isEqual:_activeRippleColor]) {
        // Same color
        return;
    }

    _activeRippleColor = activeRippleColor;
    self.activeRippleLayer.fillColor = activeRippleColor.CGColor;
}

#pragma mark - Ripple Management

- (void)updateRippleStyle {
    self.layer.masksToBounds = (self.rippleStyle == NUARippleStyleBounded);
    if (self.rippleStyle == NUARippleStyleUnbounded && self.superview.layer.shadowPath) {
        if (!self.maskLayer) {
            // Use mask layer when the superview has a shadowPath.
            self.maskLayer = [CAShapeLayer layer];
            self.maskLayer.delegate = self;
        }

        self.maskLayer.path = self.superview.layer.shadowPath;
        self.layer.mask = _maskLayer;
    } else {
        self.layer.mask = nil;
    }
}

- (void)setColorForRippleLayer:(NUARippleLayer *)rippleLayer {
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection respondsToSelector:@selector(performAsCurrentTraitCollection:)]) {
            [self.traitCollection performAsCurrentTraitCollection:^{
                rippleLayer.fillColor = self.rippleColor.CGColor;
            }];

            return;
        }
    }

    rippleLayer.fillColor = self.rippleColor.CGColor;
}

#pragma mark - Ripple Animation

- (void)cancelAllRipplesAnimated:(BOOL)animated {
    NSArray<CALayer *> *sublayers = [self.layer.sublayers copy];
    if (animated) {
        CFTimeInterval latestBeginTouchDownRippleTime = DBL_MIN;
        for (CALayer *layer in sublayers) {
            if (![layer isKindOfClass:[NUARippleLayer class]]) {
                continue;
            }

            NUARippleLayer *rippleLayer = (NUARippleLayer *)layer;
            latestBeginTouchDownRippleTime =
            MAX(latestBeginTouchDownRippleTime, rippleLayer.rippleTouchDownStartTime);
        }
        dispatch_group_t group = dispatch_group_create();
        for (CALayer *layer in sublayers) {
            if (![layer isKindOfClass:[NUARippleLayer class]]) {
                continue;
            }

            NUARippleLayer *rippleLayer = (NUARippleLayer *)layer;
            if (!rippleLayer.isStartAnimationActive) {
                rippleLayer.rippleTouchDownStartTime = latestBeginTouchDownRippleTime + NUARippleFadeOutDelay;
            }

            dispatch_group_enter(group);
            [rippleLayer endRippleAnimated:animated completion:^{
                dispatch_group_leave(group);
            }];
        }
    } else {
        for (CALayer *layer in sublayers) {
            if (![layer isKindOfClass:[NUARippleLayer class]]) {
                // Not ripple layer
                continue;
            }

            NUARippleLayer *rippleLayer = (NUARippleLayer *)layer;
            [rippleLayer removeFromSuperlayer];
        }
    }
}

- (void)fadeInRippleAnimated:(BOOL)animated {
    if (!self.activeRippleLayer) {
        // No layer
        return;
    }

    [self.activeRippleLayer fadeInRippleAnimated:animated];
}

- (void)fadeOutRippleAnimated:(BOOL)animated {
    if (!self.activeRippleLayer) {
        // No layer
        return;
    }

    [self.activeRippleLayer fadeOutRippleAnimated:animated];
}

- (void)beginRippleTouchDownAtPoint:(CGPoint)point animated:(BOOL)animated {
    // Create new layer
    NUARippleLayer *rippleLayer = [NUARippleLayer layer];
    [self updateRippleStyle];
    [self setColorForRippleLayer:rippleLayer];
    rippleLayer.frame = self.bounds;
    [self.layer addSublayer:rippleLayer];
    [rippleLayer startRippleAtPoint:point animated:animated];
    self.activeRippleLayer = rippleLayer;
}

- (void)beginRippleTouchUpAnimated:(BOOL)animated {
    if (!self.activeRippleLayer) {
        // No layer
        return;
    }

    [self.activeRippleLayer endRippleAnimated:animated completion:nil];
}

#pragma mark - CALayerDelegate

- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event {
    if ([event isEqualToString:@"path"] || [event isEqualToString:@"shadowPath"]) {
        NUARipplePendingAnimation *pendingAnim = [[NUARipplePendingAnimation alloc] init];
        pendingAnim.animationSourceLayer = self.superview.layer;
        pendingAnim.fromValue = [layer.presentationLayer valueForKey:event];
        pendingAnim.toValue = nil;
        pendingAnim.keyPath = event;

        return pendingAnim;
    }

    return nil;
}

@end

@implementation NUARipplePendingAnimation

- (void)runActionForKey:(NSString *)event object:(id)anObject arguments:(NSDictionary *)dict {
    if (![anObject isKindOfClass:[CAShapeLayer class]]) {
        return;
    }

    CAShapeLayer *layer = (CAShapeLayer *)anObject;
    CAAnimation *boundsAction = [self.animationSourceLayer animationForKey:@"bounds.size"];
    if (![boundsAction isKindOfClass:[CABasicAnimation class]]) {
        return;
    }

    CABasicAnimation *animation = (CABasicAnimation *)[boundsAction copy];
    animation.keyPath = self.keyPath;
    animation.fromValue = self.fromValue;
    animation.toValue = self.toValue;

    [layer addAnimation:animation forKey:event];
}

@end