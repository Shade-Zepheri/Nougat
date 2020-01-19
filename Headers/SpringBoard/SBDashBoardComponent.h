@interface SBDashBoardComponent : NSObject <NSCopying>
@property (copy, nonatomic) NSString *identifier;
@property (assign, nonatomic) NSInteger priority;
@property (strong, nonatomic) NSNumber *value;

+ (instancetype)homeAffordance;

- (instancetype)priority:(NSInteger)priority;
- (instancetype)identifier:(NSString *)identifier;
- (instancetype)value:(NSNumber *)value;

@end