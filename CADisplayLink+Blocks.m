#import "CADisplayLink+Blocks.h"

// DONT DO THIS
//  but im only creating 1 timer so meh
CADisplayLinkFireBlock fireBlock;

@implementation CADisplayLink (Blocks)

#pragma mark - Initialization

+ (instancetype)displayLinkWithBlock:(CADisplayLinkFireBlock)block {
    fireBlock = [block copy];

    return [self displayLinkWithTarget:self selector:@selector(NUA_fireBlock:)];
}

#pragma mark - Block execution

+ (void)NUA_fireBlock:(CADisplayLink *)displayLink {
    if (!fireBlock) {
        return;
    }

    fireBlock(displayLink);
}

@end