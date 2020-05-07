#import "NCNotificationDestination.h"

@interface NCNotificationDestinationsRegistry : NSObject
@property (strong, nonatomic) NSMutableDictionary<NSString *, id<NCNotificationDestination>> *destinations;
@property (strong, nonatomic) NSMutableDictionary<NSString *, id<NCNotificationDestination>> *activeDestinations;
@property (strong, nonatomic) NSMutableDictionary<NSString *, id<NCNotificationDestination>> *readyDestinations;
@property (readonly, nonatomic) NSUInteger count; 
@property (readonly, nonatomic) NSArray<id<NCNotificationDestination>> *registeredDestinations;

- (NSMutableSet<NSString *> *)destinationIdentifiersForRequestDestinations:(NSSet<NSString *> *)requestDestinations;
- (NSMutableSet<id<NCNotificationDestination>> *)destinationsForRequestDestinations:(NSSet<NSString *> *)requestDestinations;
- (NSMutableSet<id<NCNotificationDestination>> *)_destinationsForRequestDestinations:(NSSet<NSString *> *)requestDestinations inDestinationDict:(NSMutableDictionary<NSString *, id<NCNotificationDestination>> *)destinationDict;

@end