#import <QuartzCore/QuartzCore.h>

typedef void (^CADisplayLinkFireBlock)(CADisplayLink *displayLink);

@interface CADisplayLink (Blocks)

+ (instancetype)displayLinkWithBlock:(CADisplayLinkFireBlock)block;

@end