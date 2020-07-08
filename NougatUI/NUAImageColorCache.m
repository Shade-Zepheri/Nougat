#import "NUAImageColorCache.h"
#import <UIKit/UIImage+Private.h>

@interface NUAImageColorCache () {
    dispatch_queue_t _processingQueue;
}

@property (strong, nonatomic) NSCache<NSString *, NUAImageColorInfo *> *iconCache;
@property (strong, nonatomic) NSCache<NSString *, NUAImageColorInfo *> *albumArtworkCache;

@end

@implementation NUAImageColorCache

#pragma mark - Initialization

+ (instancetype)sharedCache {
    static NUAImageColorCache *sharedCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCache = [[self alloc] init];
    });

    return sharedCache;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // Create caches
        _iconCache = [[NSCache alloc] init];
        self.iconCache.countLimit = 23;

        _albumArtworkCache = [[NSCache alloc] init];
        self.albumArtworkCache.countLimit = 23;

        // Create background queue to work on
        dispatch_queue_attr_t attributes = dispatch_queue_attr_make_with_autorelease_frequency(DISPATCH_QUEUE_CONCURRENT, DISPATCH_AUTORELEASE_FREQUENCY_WORK_ITEM);
        dispatch_queue_attr_t calloutAttributes = dispatch_queue_attr_make_with_qos_class(attributes, QOS_CLASS_USER_INITIATED, 0);
        _processingQueue = dispatch_queue_create("com.shade.nougat.color-cache", calloutAttributes);
    }

    return self;
}

#pragma mark - Helper Methods

- (void)_analyzeImage:(UIImage *)image type:(NUAImageColorInfoType)type completion:(NUAImageColorCacheCompletion)completion {
    dispatch_async(_processingQueue, ^{
        // Get image colors
        UIImageResizeQuality resizeQuality = (type == NUAImageColorInfoTypeAppIcon) ? UIImageResizeQualityMedium : UIImageResizeQualityLow;
        UIImageColorPalette *colorPalette = [image retrieveColorPaletteWithQuality:resizeQuality];
        NUAImageColorInfo *colorInfo = [NUAImageColorInfo colorInfoFromPalette:colorPalette];

        // Completion
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(colorInfo);
        });
    });
}

#pragma mark - Cache Management

- (BOOL)hasColorDataForImageIdentifier:(NSString *)identifier type:(NUAImageColorInfoType)type {
    return [self cachedColorInfoForImageIdentifier:identifier type:type] != nil;
}

- (NUAImageColorInfo *)cachedColorInfoForImageIdentifier:(NSString *)identifier type:(NUAImageColorInfoType)type {
    // Type determines what cache we use
    switch (type) {
        case NUAImageColorInfoTypeAppIcon:
           return [self.iconCache objectForKey:identifier];
        case NUAImageColorInfoTypeAlbumArtwork:
            return [self.albumArtworkCache objectForKey:identifier];
    }
}

- (void)cacheColorInfoForImage:(UIImage *)image identifier:(NSString *)identifier type:(NUAImageColorInfoType)type completion:(NUAImageColorCacheCompletion)completion {
    // Dispatch on our queue
    [self _analyzeImage:image type:type completion:^(NUAImageColorInfo *colorInfo) {
        // Type determines what cache we add to
        switch (type) {
            case NUAImageColorInfoTypeAppIcon:
                [self.iconCache setObject:colorInfo forKey:identifier];
                break;
            case NUAImageColorInfoTypeAlbumArtwork:
                [self.albumArtworkCache setObject:colorInfo forKey:identifier];
                break;
        }

        // Call completion
        completion(colorInfo);
    }];
}

#pragma mark - Non-Caching Methods

- (void)queryColorInfoForImage:(UIImage *)image completion:(NUAImageColorCacheCompletion)completion {
    // Simply call our helper method
    [self _analyzeImage:image type:NUAImageColorInfoTypeAlbumArtwork completion:completion];
}

@end