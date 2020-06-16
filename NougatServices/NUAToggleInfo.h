#import <UIKit/UIKit.h>

@interface NUAToggleInfo : NSObject <NSCopying>
@property (copy, readonly, nonatomic) NSString *toggleIdentifier;
@property (copy, readonly, nonatomic) NSSet<NSNumber *> *supportedDeviceFamilies;
@property (copy, readonly, nonatomic) NSSet<NSString *> *requiredDeviceCapabilities;
@property (copy, readonly, nonatomic) NSString *minimumVersion;
@property (copy, readonly, nonatomic) NSURL *toggleBundleURL;

+ (instancetype)toggleInfoForBundleAtURL:(NSURL *)bundleURL;

@end