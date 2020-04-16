#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef void (^NUAPropertyAnimatorAnimationBlock)(CGFloat newValue);
typedef void (^NUAPropertyAnimatorCompletion)(BOOL finished);

@interface NUAPropertyAnimator : NSObject
@property (readonly, nonatomic) NSTimeInterval duration;
@property (getter=isRunning, readonly, nonatomic) BOOL running;
@property (assign, nonatomic) CGFloat fractionComplete;

@property (readonly, nonatomic) CGFloat initialValue;
@property (readonly, nonatomic) CGFloat finishedValue;

- (instancetype)initWithDuration:(NSTimeInterval)duration initialValue:(CGFloat)initialValue finishedValue:(CGFloat)finishedValue;
- (instancetype)initWithDuration:(NSTimeInterval)duration initialValue:(CGFloat)initialValue finishedValue:(CGFloat)finishedValue animations:(NUAPropertyAnimatorAnimationBlock)animations;
- (instancetype)initWithDuration:(NSTimeInterval)duration initialValue:(CGFloat)initialValue finishedValue:(CGFloat)finishedValue animations:(NUAPropertyAnimatorAnimationBlock)animations completion:(NUAPropertyAnimatorCompletion)completion;

- (void)addAnimations:(NUAPropertyAnimatorAnimationBlock)animation;
- (void)addCompletion:(NUAPropertyAnimatorCompletion)completion;

- (void)startAnimation;
- (void)stopAnimation:(BOOL)withoutFinishing;

@end