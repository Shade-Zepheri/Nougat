@class SBTelephonyCarrierBundleInfo;

@interface SBTelephonyManager : NSObject

+ (instancetype)sharedTelephonyManager;

- (SBTelephonyCarrierBundleInfo *)carrierBundleInfo;

@end