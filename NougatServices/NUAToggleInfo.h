#import <UIKit/UIKit.h>

@interface NUAToggleInfo : NSObject
@property (strong, readonly, nonatomic) NSURL *bundleURL;
@property (copy, readonly, nonatomic) NSString *identifier;
@property (copy, readonly, nonatomic) NSString *displayName;

+ (instancetype)toggleInfoWithBundleURL:(NSURL *)bundleURL;

- (instancetype)initWithBundleURL:(NSURL *)bundleURL;

@end