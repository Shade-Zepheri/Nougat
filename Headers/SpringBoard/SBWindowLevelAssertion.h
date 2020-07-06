#import <BaseBoard/BSInvalidatable.h>

@interface SBWindowLevelAssertion : NSObject <BSInvalidatable>
@property (readonly, nonatomic) UIWindowLevel windowLevel;
@property (readonly, nonatomic) NSInteger priority;
@property (copy, readonly, nonatomic) NSString *reason;

- (instancetype)initWithPriority:(NSInteger)priority windowLevel:(UIWindowLevel)windowLevel reason:(NSString *)reason invalidationHandler:(void(^)(void))invalidationHandler;

@end