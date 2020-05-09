#import <BaseBoard/BSSimpleAssertion.h>

@interface SBAsynchronousRenderingAssertion : BSSimpleAssertion
@property (assign, nonatomic) BOOL wantsMinificationFilter;

- (instancetype)initWithReason:(NSString *)reason;
- (instancetype)initWithReason:(NSString *)reason wantsMinificationFilter:(BOOL)wantsMinificationFilter;

@end