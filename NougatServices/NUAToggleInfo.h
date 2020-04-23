#import <UIKit/UIKit.h>

@interface NUAToggleInfo : NSObject
@property (copy, readonly, nonatomic) NSURL *bundleURL;
@property (copy, readonly, nonatomic) NSString *identifier;
@property (copy, readonly, nonatomic) NSString *displayName;
@property (strong, nonatomic, readonly) UIImage *settingsIcon;

+ (instancetype)toggleInfoForBundleAtURL:(NSURL *)bundleURL;

@end