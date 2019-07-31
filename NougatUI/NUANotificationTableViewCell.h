#import <UIKit/UIKit.h>
#import "Notifications/NUACoalescedNotification.h"
#import "Notifications/NUANotificationEntry.h"

@interface NUANotificationTableViewCell : UITableViewCell
@property (strong, nonatomic) NUACoalescedNotification *notification;

@property (getter=isExpanded, readonly, nonatomic) BOOL expanded;
@property (readonly, nonatomic) NSDate *timestamp;
@property (readonly, nonatomic) UIColor *tintColor;

@end