#import "NUARippleViewBase.h"

typedef NS_OPTIONS(NSUInteger, NUARippleState) {
    NUARippleStateNormal = 0,
    NUARippleStateHighlighted = 1 << 0,
    NUARippleStateSelected = 1 << 1,
    NUARippleStateDragged = 1 << 2
};

@interface NUADynamicRippleView : NUARippleViewBase
@property (getter=isSelected, nonatomic) BOOL selected;
@property (getter=isRippleHighlighted, nonatomic) BOOL rippleHighlighted;
@property (getter=isDragged, nonatomic) BOOL dragged;

@property (assign, nonatomic) BOOL allowsSelection;

- (UIColor *)rippleColorForState:(NUARippleState)state;
- (void)setRippleColor:(UIColor *)rippleColor forState:(NUARippleState)state;

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;

@end
