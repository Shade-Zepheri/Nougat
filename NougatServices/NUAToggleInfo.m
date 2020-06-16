#import "NUAToggleInfo.h"

@implementation NUAToggleInfo

#pragma mark - Class Helpers

+ (NSSet<NSNumber *> *)_supportedDeviceFamiliesForBundleInfoDictionary:(NSDictionary<NSString *, id> *)infoDictionary {
    // Get object for key
    NSArray<NSNumber *> *supportedDeviceFamilies = infoDictionary[@"UIDeviceFamily"] ?: [NSArray array];
    return [NSSet setWithArray:supportedDeviceFamilies];
}

+ (NSSet<NSString *> *)_requiredCapabilitiesForInfoDictionary:(NSDictionary<NSString *, id> *)infoDictionary {
    // Get object for key
    NSArray<NSString *> *requiredDeviceCapabilities = infoDictionary[@"UIRequiredDeviceCapabilities"] ?: [NSArray array];
    return [NSSet setWithArray:requiredDeviceCapabilities];
}

#pragma mark - Initialization

+ (instancetype)toggleInfoForBundleAtURL:(NSURL *)bundleURL {
    // Do some checking first
    NSDictionary<NSString *, id> *infoDictionary = (__bridge_transfer NSDictionary *)CFBundleCopyInfoDictionaryInDirectory((__bridge CFURLRef)bundleURL);
    NSString *identifier = infoDictionary[@"CFBundleIdentifier"];
    if (!identifier) {
        // No identifier, or not supported
        return nil;
    } else {
        // Pass to init
        NSSet<NSNumber *> *supportedDeviceFamilies = [self _supportedDeviceFamiliesForBundleInfoDictionary:infoDictionary];
        NSSet<NSString *> *requiredDeviceCapabilities = [self _requiredCapabilitiesForInfoDictionary:infoDictionary];
        NSString *minimumVersion = infoDictionary[@"MinimumOSVersion"];
        return [[self alloc] _initWithToggleIdentifier:identifier supportedDeviceFamilies:supportedDeviceFamilies requiredDeviceCapabilities:requiredDeviceCapabilities minimumVersion:minimumVersion toggleBundleURL:bundleURL];
    }
}

- (instancetype)_initWithToggleIdentifier:(NSString *)toggleIdentifier supportedDeviceFamilies:(NSSet<NSNumber *> *)supportedDeviceFamilies requiredDeviceCapabilities:(NSSet<NSString *> *)requiredDeviceCapabilities minimumVersion:(NSString *)minimumVersion toggleBundleURL:(NSURL *)toggleBundleURL {
    self = [super init];
    if (self) {
        // Set properties
        _toggleIdentifier = [toggleIdentifier copy];
        _supportedDeviceFamilies = [supportedDeviceFamilies copy];
        _requiredDeviceCapabilities = [requiredDeviceCapabilities copy];
        _minimumVersion = [minimumVersion copy];
        _toggleBundleURL = [toggleBundleURL copy];
    }

    return self;
}

#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; Toggle Identifier: %@; Supported Device Families: %@; Required Device Capabilities: %@; Minimum Version: %@; Toggle Bundle URL: %@>", self.class, self, self.toggleIdentifier, self.supportedDeviceFamilies, self.requiredDeviceCapabilities, self.minimumVersion, self.toggleBundleURL];
}

- (BOOL)isEqual:(id)object {
    if (object == self) {
        // Same object
        return YES;
    }

    if (![object isKindOfClass:self.class]) {
        // Not the same class
        return NO;
    }

    // Compare all properties
    NUAToggleInfo *toggleInfo = (NUAToggleInfo *)object;
    BOOL sameIdentifier = [toggleInfo.toggleIdentifier isEqualToString:self.toggleIdentifier];
    BOOL sameSupportedDevices = [toggleInfo.supportedDeviceFamilies isEqualToSet:self.supportedDeviceFamilies];
    BOOL sameRequiredCapabilities = [toggleInfo.requiredDeviceCapabilities isEqualToSet:self.requiredDeviceCapabilities];
    BOOL sameMinimumVersion = [toggleInfo.minimumVersion isEqualToString:self.minimumVersion];
    BOOL sameBundleURL = [toggleInfo.toggleBundleURL isEqual:self.toggleBundleURL];
    return sameIdentifier && sameSupportedDevices && sameRequiredCapabilities && sameMinimumVersion && sameBundleURL;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end