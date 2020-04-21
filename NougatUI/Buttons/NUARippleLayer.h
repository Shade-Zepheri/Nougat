#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@class NUARippleLayer;

typedef void (^NUARippleCompletionBlock)(void);

@interface NUARippleLayer : CAShapeLayer
@property (getter=isStartAnimationActive, readonly, nonatomic) BOOL startAnimationActive;
@property (assign, nonatomic) CFTimeInterval rippleTouchDownStartTime;

- (void)startRippleAtPoint:(CGPoint)point animated:(BOOL)animated;
- (void)endRippleAnimated:(BOOL)animated completion:(NUARippleCompletionBlock)completion;

- (void)fadeInRippleAnimated:(BOOL)animated;
- (void)fadeOutRippleAnimated:(BOOL)animated;

@end