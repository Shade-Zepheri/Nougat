#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface NUARippleLayer : CAShapeLayer
@property (getter=isStartAnimationActive, assign, readonly, nonatomic) BOOL startAnimationActive;
@property (assign, nonatomic) CGFloat endAnimationDelay;

@property (assign, nonatomic) CGFloat finalRadius;
@property (assign, nonatomic) CGFloat initialRadius;
@property (assign, nonatomic) CGFloat maxRippleRadius;

@property (strong, nonatomic) UIColor *rippleColor;

- (void)startRippleAtPoint:(CGPoint)point animated:(BOOL)animated;

- (void)endRippleAtPoint:(CGPoint)point animated:(BOOL)animated;

@end