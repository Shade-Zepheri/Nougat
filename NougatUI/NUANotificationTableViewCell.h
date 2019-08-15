#import "NUATableViewCell.h"
#import "NUACoalescedNotification.h"
#import "NUANotificationEntry.h"

@class NUANotificationTableViewCell;

@protocol NUANotificationTableViewCellDelegate <NSObject>
@required

- (void)notificationTableViewCellRequestsExecuteDefaultAction:(NUANotificationTableViewCell *)cell;
- (void)notificationTableViewCellRequestsExecuteAlternateAction:(NUANotificationTableViewCell *)cell;

@end

@interface NUANotificationTableViewCell : NUATableViewCell
@property (weak, nonatomic) id<NUANotificationTableViewCellDelegate> actionsDelegate;
@property (strong, nonatomic) NUACoalescedNotification *notification;

@property (readonly, nonatomic) NSDate *timestamp;
@property (readonly, nonatomic) UIColor *tintColor;

@end