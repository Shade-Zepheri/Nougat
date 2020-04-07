#import "NUATableViewCell.h"
#import "NUACoalescedNotification.h"
#import "NUADateLabelRepository.h"
#import "NUAImageColorCache.h"

@class NUANotificationTableViewCell;

@protocol NUANotificationTableViewCellDelegate <NSObject>
@required

- (void)notificationTableViewCellRequestsExecuteDefaultAction:(NUANotificationTableViewCell *)cell;
- (void)notificationTableViewCellRequestsExecuteAlternateAction:(NUANotificationTableViewCell *)cell;

@end

@interface NUANotificationTableViewCell : NUATableViewCell <NUADateLabelDelegate>
@property (weak, nonatomic) id<NUANotificationTableViewCellDelegate> actionsDelegate;
@property (strong, nonatomic) NUACoalescedNotification *notification;

@property (strong, readonly, nonatomic) NUARelativeDateLabel *dateLabel;
@property (strong, readonly, nonatomic) NSDate *timestamp;
@property (strong, readonly, nonatomic) NUAImageColorInfo *colorInfo;

@end