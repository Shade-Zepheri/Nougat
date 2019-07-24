#import "SBNotificationDestination.h"

@interface SBNCNotificationDispatcher : NSObject
@property (readonly, nonatomic) id<SBNotificationDestination> dashBoardDestination;

@end