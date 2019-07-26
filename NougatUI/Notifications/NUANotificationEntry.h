#import <UIKit/UIKit.h>

@interface NUANotificationEntry : NSObject
@property (copy, readonly, nonatomic) NSString *title;
@property (copy, readonly, nonatomic) NSString *message;
@property (strong, readonly, nonatomic) NSDate *timestamp;

+ (instancetype)notificationEntryWithTitle:(NSString *)title message:(NSString *)message timestamp:(NSDate *)timestamp;

@end