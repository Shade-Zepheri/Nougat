@interface BSServiceConnectionEndpoint : NSObject <NSCopying, NSSecureCoding>
@property (readonly, nonatomic) NSString *_machName;
@property (copy, readonly, nonatomic) NSString *targetDescription;
@property (copy, readonly, nonatomic) NSString *service;
@property (copy, readonly, nonatomic) NSString *instance;

+ (instancetype)endpointForMachName:(NSString *)machName service:(NSString *)service instance:(NSString *)instance;

@end