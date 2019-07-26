@interface NCNotificationAction : NSObject
@property (copy, readonly, nonatomic) NSString *identifier;
@property (copy, readonly, nonatomic) NSString *title;
@property (copy, readonly, nonatomic) NSURL *launchURL;
@property (copy, readonly, nonatomic) NSString *launchBundleID;

@end