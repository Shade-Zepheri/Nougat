#import "NUADisplayLink.h"

@implementation NUADisplayLink

+ (instancetype)displayLinkWithBlock:(CADisplayLinkFireBlock)block {
    return [[self alloc] initWithBlock:block];
}

- (instancetype)initWithBlock:(CADisplayLinkFireBlock)block {
    self = [super init];
    if (self) {
        self.block = [block copy];

        // Create displaylink
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkDidFire:)];
        [self.displayLink addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
    }

    return self;
}

- (void)invalidate {
    if (!self.displayLink) {
        return;
    }

    [self.displayLink invalidate];
}

#pragma mark - Callback

- (void)displayLinkDidFire:(CADisplayLink *)displayLink {
    if (!self.block) {
        return;
    }

    self.block(displayLink);
}


@end