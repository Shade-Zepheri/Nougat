#import "NUAPropertyAnimator.h"

@interface NUAPropertyAnimator ()
@property (strong, nonatomic) NSMutableArray<NUAPropertyAnimatorAnimationBlock> *animations;
@property (strong, nonatomic) NSMutableArray<NUAPropertyAnimatorCompletion> *completions;

@property (strong, nonatomic) CADisplayLink *displayLink;
@property (assign, nonatomic) CGFloat quantityToAdd;
@property (assign, nonatomic) NSInteger totalSteps;
@property (assign, nonatomic) NSInteger currentStep;

@end

@implementation NUAPropertyAnimator

#pragma mark - Initialization

- (instancetype)initWithDuration:(NSTimeInterval)duration initialValue:(CGFloat)initialValue finishedValue:(CGFloat)finishedValue {
    return [self initWithDuration:duration initialValue:initialValue finishedValue:finishedValue animations:nil completion:nil];
}

- (instancetype)initWithDuration:(NSTimeInterval)duration initialValue:(CGFloat)initialValue finishedValue:(CGFloat)finishedValue animations:(NUAPropertyAnimatorAnimationBlock)animations {
    return [self initWithDuration:duration initialValue:initialValue finishedValue:finishedValue animations:animations completion:nil];
}

- (instancetype)initWithDuration:(NSTimeInterval)duration initialValue:(CGFloat)initialValue finishedValue:(CGFloat)finishedValue animations:(NUAPropertyAnimatorAnimationBlock)animations completion:(NUAPropertyAnimatorCompletion)completion {
    self = [super init];
    if (self) {
        // Create defaults
        _animations = [NSMutableArray array];
        _completions = [NSMutableArray array];
        _totalSteps = [self _numberOfStepsForDuration:duration];
        _currentStep = 0;

        // Set defautls
        _duration = duration;
        _initialValue = initialValue;
        _finishedValue = finishedValue;
        _quantityToAdd = finishedValue - initialValue;

        // Add blocks if exist
        if (animations) {
            [_animations addObject:[animations copy]];
        }

        if (completion) {
            [_completions addObject:[completion copy]];
        }
    }

    return self;
}

- (void)dealloc {
    // Stop display link
    [self _stopDisplayLink];
}

#pragma mark - Timing Helpers

- (CGFloat)_multiplerAdjustedWithEasing:(CGFloat)t {
    // Use material design spec bezier curve to get multiplier
    CGFloat xForT = (0.6 * (1 - t) * t * t) + (1.2 * (1 - t) * (1 - t) * t) + ((1 - t) * (1 - t) * (1 - t));
    CGFloat yForX = (3 * xForT * xForT * (1 - xForT)) + (xForT * xForT * xForT);
    return 1 - yForX;
}

- (NSInteger)_numberOfStepsForDuration:(NSTimeInterval)duration {
    // We want the animation to last 1/3 sec, so the number of frames executed depends on the device refresh rate
    UIScreen *mainScreen = [UIScreen mainScreen];
    if ([mainScreen respondsToSelector:@selector(maximumFramesPerSecond)]) {
        // Actually applies
        NSInteger maximumFramesPerSecond = mainScreen.maximumFramesPerSecond;
        return maximumFramesPerSecond * duration;
    } else {
        // Doesn't apply on < iOS 10.3
        return 60 * duration; 
    }
}

- (CGFloat)_newValueForStep:(NSInteger)step {
    // Calculate fraction done
    CGFloat fractionComplete = (CGFloat)step / self.totalSteps;
    self.fractionComplete = fractionComplete;

    // Apply multiplier
    CGFloat multiplier = [self _multiplerAdjustedWithEasing:fractionComplete];
    return self.initialValue + (self.quantityToAdd * multiplier);
}

#pragma mark - Block Management

- (void)addAnimations:(NUAPropertyAnimatorAnimationBlock)animation {
    // Simply add to array
    [self.animations addObject:[animation copy]];
}

- (void)addCompletion:(NUAPropertyAnimatorCompletion)completion {
    // Simply add to array
    [self.completions addObject:[completion copy]];
}

#pragma mark - Start/Stop 

- (void)startAnimation {
    // Call to start out display link
    [self _startDisplayLink];
}

- (void)stopAnimation:(BOOL)withoutFinishing {
    // stop our display link
    [self _stopDisplayLink];

    // Pass to our completions
    for (NUAPropertyAnimatorCompletion completionBlock in self.completions) {
        completionBlock(!withoutFinishing);
    }
}

#pragma mark - DisplayLink Management

- (void)_startDisplayLink {
    if (self.displayLink) {
        // Already exists
        return;
    }

    // Set flag
    _running = YES;

    // Create and start timer
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(_displayLinkDidFire:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)_displayLinkDidFire:(CADisplayLink *)displayLink {
    if (self.currentStep == self.totalSteps) {
        // Run completions (they will be the final step)
        for (NUAPropertyAnimatorCompletion completionBlock in self.completions) {
            completionBlock(YES);
        }

        // Stop timer
        [self _stopDisplayLink];

        return;
    }

    // Increment setp
    self.currentStep++;

    // Calculate new value
    CGFloat newValue = [self _newValueForStep:self.currentStep];

    // Pass to animations
    for (NUAPropertyAnimatorAnimationBlock animationBlock in self.animations) {
        animationBlock(newValue);
    }
}

- (void)_stopDisplayLink {
    if (!self.displayLink) {
        // Already gone
        return;
    }

    // Finished, set flag
    _running = NO;

    [self.displayLink invalidate];
    self.displayLink = nil;
}

@end