#import "SBNotificationDestination.h"

@class NCNotificationDispatcher, SBNotificationBannerDestination;

@interface SBNCNotificationDispatcher : NSObject
@property (strong, nonatomic) NCNotificationDispatcher *dispatcher;
@property (readonly, nonatomic) SBNotificationBannerDestination *bannerDestination;
@property (readonly, nonatomic) id<SBNotificationDestination> dashBoardDestination;

@end