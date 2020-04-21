#import "NUADynamicRippleView.h"
#import "NUARippleLayer.h"

static const CGFloat NUADefaultRippleAlpha = 0.12;
static const CGFloat NUADefaultRippleSelectedAlpha = 0.08;
static const CGFloat NUADefaultRippleDraggedAlpha = 0.08;

// Expose private inherited stuffs
@interface NUARippleViewBase ()
@property (strong, nonatomic) NUARippleLayer *activeRippleLayer;

@end

@interface NUADynamicRippleView () {
    NSMutableDictionary<NSNumber *, UIColor *> *_rippleColors;
    BOOL _tapWentOutsideOfBounds;
    BOOL _tapWentInsideOfBounds;
    BOOL _didReceiveTouch;
    CGPoint _lastTouch;
}

@end

@implementation NUADynamicRippleView

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Set default colors
        _rippleColors = [NSMutableDictionary dictionary];
        UIColor *selectionColor = [UIColor colorWithRed:0.384 green:0 blue:0.933 alpha:1.0];
        _rippleColors[@(NUARippleStateNormal)] = [UIColor colorWithWhite:0 alpha:NUADefaultRippleAlpha];
        _rippleColors[@(NUARippleStateHighlighted)] = [UIColor colorWithWhite:0 alpha:NUADefaultRippleAlpha];
        _rippleColors[@(NUARippleStateSelected)] = [selectionColor colorWithAlphaComponent:NUADefaultRippleSelectedAlpha];
        _rippleColors[@(NUARippleStateSelected | NUARippleStateHighlighted)] = [selectionColor colorWithAlphaComponent:NUADefaultRippleAlpha];
        _rippleColors[@(NUARippleStateDragged)] = [UIColor colorWithWhite:0 alpha:NUADefaultRippleDraggedAlpha];
        _rippleColors[@(NUARippleStateDragged | NUARippleStateHighlighted)] = [UIColor colorWithWhite:0 alpha:NUADefaultRippleDraggedAlpha];
        _rippleColors[@(NUARippleStateSelected | NUARippleStateDragged)] = [selectionColor colorWithAlphaComponent:NUADefaultRippleDraggedAlpha];
    }

    return self;
}

#pragma mark - Properties

- (void)setAllowsSelection:(BOOL)allowsSelection {
    if (!allowsSelection && self.selected) {
        self.selected = NO;
    }

    _allowsSelection = allowsSelection;
}

- (void)setSelected:(BOOL)selected {
    if (!self.allowsSelection) {
        // No selecting allowed
        return;
    } else if (_tapWentOutsideOfBounds) {
        // Not in bounds
        return;
    } else if (selected == _selected && self.activeRippleLayer) {
        // Already selected
        return;
    }

    _selected = selected;

    // Go into the selected state visually.
    if (selected) {
        if (!self.activeRippleLayer) {
            // Create ripple
            [self updateRippleColor];
            [self beginRippleTouchDownAtPoint:_lastTouch animated:NO];
        } else {
            [self updateActiveRippleColor];
        }
    } else {
        // Cancel ripples.
        [self updateRippleColor];
        [self cancelAllRipplesAnimated:YES];
    }
}

- (void)setRippleHighlighted:(BOOL)rippleHighlighted {
    if (rippleHighlighted == _rippleHighlighted) {
        // No change
        return;
    }

    _rippleHighlighted = rippleHighlighted;

    if (rippleHighlighted && !_tapWentInsideOfBounds) {
        // Start ripple
        [self updateRippleColor];
        [self beginRippleTouchDownAtPoint:_lastTouch animated:_didReceiveTouch];
    } else if (!rippleHighlighted) {
        BOOL notAllowingSelectionOrAlreadySelected = !self.allowsSelection || self.selected;
        BOOL shouldDissolveRipple = notAllowingSelectionOrAlreadySelected && !self.dragged && !_tapWentOutsideOfBounds;

        if (shouldDissolveRipple) {
            // Stop ripple
            [self updateRippleColor];
            [self beginRippleTouchUpAnimated:YES];
        }
    }
}

- (void)setDragged:(BOOL)dragged {
    if (dragged == _dragged) {
        // No change
        return;
    }

    _dragged = dragged;

    if (dragged) {
        if (!self.activeRippleLayer) {
            // Create ripple
            [self updateRippleColor];
            [self beginRippleTouchDownAtPoint:_lastTouch animated:NO];
        } else {
            [self updateActiveRippleColor];
        }
    } else {
        // Stop ripple
        [self updateRippleColor];
        [self cancelAllRipplesAnimated:YES];
    }
}

#pragma mark - Colors

- (UIColor *)rippleColorForState:(NUARippleState)state {
    UIColor *rippleColor = _rippleColors[@(state)];
    if (!rippleColor && (state & NUARippleStateDragged) != 0) {
        rippleColor = _rippleColors[@(NUARippleStateDragged)];
    } else if (!rippleColor && (state & NUARippleStateSelected) != 0) {
        rippleColor = _rippleColors[@(NUARippleStateSelected)];
    }

    if (!rippleColor) {
        rippleColor = _rippleColors[@(NUARippleStateNormal)];
    }
    return rippleColor;
}

- (void)setRippleColor:(UIColor *)rippleColor forState:(NUARippleState)state {
    // Add to dict and update
    _rippleColors[@(state)] = rippleColor;

    [self updateRippleColor];
}

- (void)updateRippleColor {
    UIColor *rippleColor = [self rippleColorForState:self.state];
    self.rippleColor = rippleColor;
}

- (void)updateActiveRippleColor {
    UIColor *rippleColor = [self rippleColorForState:self.state];
    self.activeRippleColor = rippleColor;
}

- (NUARippleState)state {
    NUARippleState state = NUARippleStateNormal;
    if (self.selected) {
        state |= NUARippleStateSelected;
    }
    if (self.rippleHighlighted) {
        state |= NUARippleStateHighlighted;
    }
    if (self.dragged) {
        state |= NUARippleStateDragged;
    }

    return state;
}

#pragma mark - Touches

- (BOOL)pointInsideSuperview:(CGPoint)point withEvent:(UIEvent *)event {
    // Defer to superview
    return [self.superview pointInside:point withEvent:event];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];

    // Set initial info
    _lastTouch = point;
    if (_didReceiveTouch) {
        // Already has touch
        return;
    }

    _didReceiveTouch = YES;
    _tapWentInsideOfBounds = NO;
    _tapWentOutsideOfBounds = NO;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];

    // Check if moved out
    BOOL pointContainedInSuperview = [self pointInsideSuperview:point withEvent:event];
    if (pointContainedInSuperview && _tapWentOutsideOfBounds) {
        _tapWentInsideOfBounds = YES;
        _tapWentOutsideOfBounds = NO;
        [self fadeInRippleAnimated:YES];
    } else if (!pointContainedInSuperview && !_tapWentOutsideOfBounds) {
        _tapWentOutsideOfBounds = YES;
        [self fadeOutRippleAnimated:YES];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _didReceiveTouch = NO;
    if (!_tapWentOutsideOfBounds) {
        return;
    }

    [self beginRippleTouchUpAnimated:NO];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // Just stop everything
    _didReceiveTouch = NO;
    [self beginRippleTouchUpAnimated:YES];
}

@end