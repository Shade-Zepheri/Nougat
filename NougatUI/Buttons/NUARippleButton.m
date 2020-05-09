// Copyright 2016-present the Material Components for iOS authors. All Rights Reserved.
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

#import "NUARippleButton.h"
#import <math.h>

@interface NUARippleButton () {
    CGFloat _enabledAlpha;
}
@property (strong, nonatomic) NUADynamicRippleView *rippleView;

@end

static inline CGRect rectAlignToScale(CGRect rect, CGFloat scale) {
    if (CGRectIsNull(rect)) {
        // No rect
        return CGRectNull;
    } else if (scale == 1.0) {
        // Basically what CGRectIntegral is for
        return CGRectIntegral(rect);
    } else {
        // Manually round
        CGPoint originalOrigin = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
        CGPoint newOrigin = CGPointMake(floor(originalOrigin.x * scale) / scale, floor(originalOrigin.y * scale) / scale);
        CGSize adjustWidthHeight = CGSizeMake(originalOrigin.x - newOrigin.x, originalOrigin.y - newOrigin.y);
        return CGRectMake(newOrigin.x, newOrigin.y, ceil((CGRectGetWidth(rect) + adjustWidthHeight.width) * scale) / scale, ceil((CGRectGetHeight(rect) + adjustWidthHeight.height) * scale) / scale);
    }
}

@implementation NUARippleButton

#pragma mark - Initialization

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Just pass to helper
        [self _setupDefaults];
    }

    return self;
}

- (void)_setupDefaults {
    // Set default values
    _disabledAlpha = 0.12;
    _enabledAlpha = self.alpha;

    // Disable default highlight state.
    self.adjustsImageWhenHighlighted = NO;
    self.showsTouchWhenHighlighted = NO;

    // Create bounding path
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius].CGPath;

    // Create ripple layer
    self.rippleView = [[NUADynamicRippleView alloc] initWithFrame:self.bounds];
    self.rippleView.rippleColor = [UIColor colorWithWhite:1 alpha:0.12];
    [self insertSubview:self.rippleView belowSubview:self.imageView];

    // Register for touch stuff
    self.exclusiveTouch = YES;

    // Content insets
    self.contentEdgeInsets = UIEdgeInsetsMake(8, 16, 8, 16);
}

- (void)dealloc {
    // Remove observers
    [self removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
}

#pragma mark - Properties

- (NUARippleStyle)rippleStyle {
  return self.rippleView.rippleStyle;
}

- (void)setRippleStyle:(NUARippleStyle)rippleStyle {
    if (rippleStyle == self.rippleView.rippleStyle) {
        // Same style
        return;
    }

    // Pass to ripple view
    self.rippleView.rippleStyle = rippleStyle;
}

- (UIColor *)rippleColor {
  return self.rippleView.rippleColor;
}

- (void)setRippleColor:(UIColor *)rippleColor {
    // Pass to ripple view
    [self.rippleView setRippleColor:rippleColor forState:NUARippleStateHighlighted];
}

#pragma mark - UIView Methods

- (void)layoutSubviews {
    [super layoutSubviews];

    // Update bounding path
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius].CGPath;

    // Update ripple view frame
    self.rippleView.frame = CGRectStandardize(self.bounds);

    // Title label aligning
    self.titleLabel.frame = rectAlignToScale(self.titleLabel.frame, [UIScreen mainScreen].scale);
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // Check if custom bounds
    if (!UIEdgeInsetsEqualToEdgeInsets(self.touchAreaInsets, UIEdgeInsetsZero)) {
        return CGRectContainsPoint(UIEdgeInsetsInsetRect(CGRectStandardize(self.bounds), self.touchAreaInsets), point);
    }

    // Defer to nromal
    return [super pointInside:point withEvent:event];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    // Stop all animations
    [super willMoveToSuperview:newSuperview];
    [self.rippleView cancelAllRipplesAnimated:NO];
}

- (CGSize)intrinsicContentSize {
    return [self sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
}

#pragma mark - Touch Methods

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // Pass to ripple view
    [self.rippleView touchesBegan:touches withEvent:event];

    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // Pass to ripple view
    [self.rippleView touchesMoved:touches withEvent:event];

    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // Pass to ripple view
    [self.rippleView touchesEnded:touches withEvent:event];

    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // Pass to ripple view
    [self.rippleView touchesCancelled:touches withEvent:event];

    [super touchesCancelled:touches withEvent:event];
}

#pragma mark - UIControl Methods

- (void)setEnabled:(BOOL)enabled {
    // Make sure our method called
    [self setEnabled:enabled animated:NO];
}

- (void)setEnabled:(BOOL)enabled animated:(BOOL)animated {
    [super setEnabled:enabled];

    // Update settings
    [self updateAfterStateChange:animated];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];

    // Pass to ripple view
    self.rippleView.rippleHighlighted = highlighted;
    [self updateAfterStateChange:NO];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];

    // Pass to ripple view
    self.rippleView.selected = selected;
    [self updateAfterStateChange:NO];
}

- (void)updateAfterStateChange:(BOOL)animated {
    // Update our alpha
    CGFloat duration = animated ? 0.2 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        self.alpha = self.enabled ? _enabledAlpha : self.disabledAlpha;
    }];
}

@end