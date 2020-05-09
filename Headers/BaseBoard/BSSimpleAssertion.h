#import "BSInvalidatable.h"

@interface BSSimpleAssertion : NSObject <BSInvalidatable>
@property (copy, readonly, nonatomic) NSString *identifier;
@property (copy, readonly, nonatomic) NSString *reason;
@property (getter=isValid, readonly, nonatomic) BOOL valid;

- (instancetype)initWithIdentifier:(NSString *)identifier forReason:(NSString *)reason invalidationBlock:(void(^)(void))invalidationBlock ;
- (instancetype)initWithIdentifier:(NSString *)identifier forReason:(NSString *)reason queue:(dispatch_queue_t)queue invalidationBlock:(void(^)(void))invalidationBlock;

@end