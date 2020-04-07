#import <UIKit/UIKit.h>

@interface NUAImageColorInfo : NSObject
@property (strong, readonly, nonatomic) UIColor *primaryColor;
@property (strong, readonly, nonatomic) UIColor *accentColor;

+ (instancetype)colorInfoWithPrimaryColor:(UIColor *)primaryColor accentColor:(UIColor *)accentColor;

@end

typedef NS_ENUM(NSUInteger, NUAImageColorInfoType) {
    NUAImageColorInfoTypeAppIcon,
    NUAImageColorInfoTypeAlbumArtwork
};

typedef void (^NUAImageColorCacheCompletion)(NUAImageColorInfo *colorInfo);

@interface NUAImageColorCache : NSObject
@property (class, strong, readonly) NUAImageColorCache *sharedCache;

@property (strong, readonly, nonatomic) NSCache<UIImage *, NUAImageColorInfo *> *iconCache;
@property (strong, readonly, nonatomic) NSCache<UIImage *, NUAImageColorInfo *> *albumArtworkCache;

- (BOOL)hasColorDataForImage:(UIImage *)image type:(NUAImageColorInfoType)type;
- (NUAImageColorInfo *)cachedColorInfoForImage:(UIImage *)image type:(NUAImageColorInfoType)type;
- (void)cacheColorInfoForImage:(UIImage *)image type:(NUAImageColorInfoType)type completion:(NUAImageColorCacheCompletion)completion;

- (void)queryColorInfoForImage:(UIImage *)image completion:(NUAImageColorCacheCompletion)completion;

@end
