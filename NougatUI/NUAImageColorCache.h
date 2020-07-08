#import "NUAImageColorInfo.h"

typedef NS_ENUM(NSUInteger, NUAImageColorInfoType) {
    NUAImageColorInfoTypeAppIcon,
    NUAImageColorInfoTypeAlbumArtwork
};

typedef void (^NUAImageColorCacheCompletion)(NUAImageColorInfo *colorInfo);

@interface NUAImageColorCache : NSObject
@property (class, strong, readonly) NUAImageColorCache *sharedCache;

- (BOOL)hasColorDataForImageIdentifier:(NSString *)identifier type:(NUAImageColorInfoType)type;
- (NUAImageColorInfo *)cachedColorInfoForImageIdentifier:(NSString *)identifier type:(NUAImageColorInfoType)type;
- (void)cacheColorInfoForImage:(UIImage *)image identifier:(NSString *)identifier type:(NUAImageColorInfoType)type completion:(NUAImageColorCacheCompletion)completion;

- (void)queryColorInfoForImage:(UIImage *)image completion:(NUAImageColorCacheCompletion)completion;

@end
