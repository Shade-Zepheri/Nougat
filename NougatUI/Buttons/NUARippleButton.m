#import "NUARippleButton.h"

@interface NUARippleButton ()
@property (strong, nonatomic) NUADynamicRippleView *rippleView;

@end

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

    // Some title label stuffs
    // self.titleLabel.frame = MDCRectAlignToScale(self.titleLabel.frame, [UIScreen mainScreen].scale);
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

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];

    // Pass to ripple view
    self.rippleView.rippleHighlighted = highlighted;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];

    // Pass to ripple view
    self.rippleView.selected = selected;
}

@end