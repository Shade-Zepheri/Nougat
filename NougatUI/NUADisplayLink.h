#import <QuartzCore/QuartzCore.h>

typedef void (^CADisplayLinkFireBlock)(CADisplayLink *displayLink);

@interface NUADisplayLink : NSObject
@property (strong, readonly, nonatomic) CADisplayLink *displayLink;
@property (copy, nonatomic) CADisplayLinkFireBlock block;

+ (instancetype)displayLinkWithBlock:(CADisplayLinkFireBlock)block;

- (void)invalidate;

@end