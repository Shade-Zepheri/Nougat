#import <UIKit/UIKit.h>
#import "NUANotificationEntry.h"

typedef NS_ENUM(NSUInteger, NUANotificationType) {
    NUANotificationTypeNotification,
    NUANotificationTypeMedia
};

@interface NUACoalescedNotification : NSObject
@property (copy, readonly, nonatomic) NSString *sectionID;
@property (copy, readonly, nonatomic) NSString *title;
@property (copy, readonly, nonatomic) NSString *message;
@property (strong, readonly, nonatomic) UIImage *icon;
@property (strong, readonly, nonatomic) NSDate *timestamp;
@property (copy, readonly, nonatomic) NSArray<NUANotificationEntry *> *entries;
@property (assign, nonatomic) NUANotificationType type;

+ (instancetype)mediaNotification;

+ (instancetype)coalescedNotificationWithSectionID:(NSString *)sectionID title:(NSString *)title message:(NSString *)message entires:(NSArray<NUANotificationEntry *> *)entries;
- (instancetype)initWithSectionID:(NSString *)sectionID title:(NSString *)title message:(NSString *)message entires:(NSArray<NUANotificationEntry *> *)entries;

@end