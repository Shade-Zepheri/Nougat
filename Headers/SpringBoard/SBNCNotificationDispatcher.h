#import "SBNotificationDestination.h"

@class SBNotificationBannerDestination;

@interface SBNCNotificationDispatcher : NSObject
@property (readonly, nonatomic) SBNotificationBannerDestination *bannerDestination;
@property (readonly, nonatomic) id<SBNotificationDestination> dashBoardDestination;

@end