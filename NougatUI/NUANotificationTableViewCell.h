#import <UIKit/UIKit.h>
#import "Notifications/NUACoalescedNotification.h"
#import "Notifications/NUANotificationEntry.h"

@interface NUANotificationTableViewCell : UITableViewCell
@property (strong, nonatomic) NUACoalescedNotification *notification;

@property (readonly, nonatomic) NSDate *timestamp;

@end