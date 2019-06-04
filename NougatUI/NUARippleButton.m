#import "NUARippleButton.h"
#import "NUARippleLayer.h"

@interface NUARippleButton ()
@property (strong, readonly, nonatomic) UIColor *rippleColor;
@property (strong, nonatomic) NUARippleLayer *activeRippleLayer;

@end

@implementation NUARippleButton

+ (Class)layerClass {
    return NUARippleLayer.class;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Register for dragging events
        [self addTarget:self action:@selector(touchDragEnter:forEvent:) forControlEvents:UIControlEventTouchDragEnter];
        [self addTarget:self action:@selector(touchDragExit:forEvent:) forControlEvents:UIControlEventTouchDragExit];
    }

    return self;
}

- (void)dealloc {
    // Deregister from dragging events
    [self removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
}

- (void)layoutSubviews {
    // Update bounds
    self.layer.bounds = self.bounds;
    self.layer.masksToBounds = YES;

    // Update all sublayer bounds
    for (CALayer *layer in self.layer.sublayers) {
        if (![layer isKindOfClass:NUARippleLayer.class]) {
            continue;
        }

        layer.bounds = self.bounds;
    }
}

- (UIColor *)rippleColor {
    return [UIColor colorWithWhite:0 alpha:0.14];
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];

    [self handleBeginTouches:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];

    // Use -touchDragExit:forEvent: and -touchDragEnter:forEvent:
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];

    CGPoint location = [self locationFromTouches:touches];
    [self evaporateInkToPoint:location];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];

    [self evaporateInkToPoint:[self locationFromTouches:touches]];
}

#pragma mark - Dragging

- (void)touchDragEnter:(__unused NUARippleButton *)button forEvent:(UIEvent *)event {
    [self handleBeginTouches:event.allTouches];
}

- (void)touchDragExit:(__unused NUARippleButton *)button forEvent:(UIEvent *)event {
    CGPoint location = [self locationFromTouches:event.allTouches];
    [self evaporateInkToPoint:location];
}

#pragma mark - Helpers

- (void)handleBeginTouches:(NSSet *)touches {
    CGPoint point = [self locationFromTouches:touches];
    [self startTouchBeganAtPoint:point animated:YES];
}

- (CGPoint)locationFromTouches:(NSSet *)touches {
    UITouch *touch = [touches anyObject];
    return [touch locationInView:self];
}

- (void)evaporateInkToPoint:(CGPoint)toPoint {
    [self startTouchEndAtPoint:toPoint animated:YES];
}

#pragma mark - Ripple

- (void)startTouchBeganAtPoint:(CGPoint)point animated:(BOOL)animated {
    NUARippleLayer *rippleLayer = [NUARippleLayer layer];
    rippleLayer.rippleColor = self.rippleColor;
    rippleLayer.maxRippleRadius = 0;
    rippleLayer.opacity = 0;
    rippleLayer.frame = self.bounds;
    [self.layer addSublayer:rippleLayer];
    [rippleLayer startRippleAtPoint:point animated:animated];
    self.activeRippleLayer = rippleLayer;
}

- (void)startTouchEndAtPoint:(CGPoint)point animated:(BOOL)animated {
    [self.activeRippleLayer endRippleAtPoint:point animated:animated];
}

@end