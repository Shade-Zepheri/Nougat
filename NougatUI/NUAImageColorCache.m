#import "NUAImageColorCache.h"
#import "UIColor+Accent.h"

@implementation NUAImageColorInfo

#pragma mark - Initialization

+ (instancetype)colorInfoWithPrimaryColor:(UIColor *)primaryColor accentColor:(UIColor *)accentColor {
    return [[self alloc] initWithPrimaryColor:primaryColor accentColor:accentColor];
}

- (instancetype)initWithPrimaryColor:(UIColor *)primaryColor accentColor:(UIColor *)accentColor {
    self = [super init];
    if (self) {
        // Simply set properties
        _primaryColor = primaryColor;
        _accentColor = accentColor;
    }

    return self;
}

@end


@interface NUAImageColorCache () {
    dispatch_queue_t _processingQueue;
}

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
        dispatch_queue_attr_t attributes = dispatch_queue_attr_make_with_autorelease_frequency(DISPATCH_QUEUE_SERIAL, DISPATCH_AUTORELEASE_FREQUENCY_WORK_ITEM);
        dispatch_queue_attr_t calloutAttributes = dispatch_queue_attr_make_with_qos_class(attributes, QOS_CLASS_USER_INITIATED, 0);
        _processingQueue = dispatch_queue_create("com.shade.nougat.color-cache", calloutAttributes);

        // TODO: Register for any app color changes
    }

    return self;
}

#pragma mark - Helper Methods

- (UIColor *)_averageColorForImage:(UIImage *)image {
    CIImage *inputImage = image.CIImage ?: [CIImage imageWithCGImage:image.CGImage];
    if (!inputImage) {
        // No image, fallback
        return UIColor.grayColor;
    }

    CIFilter *filter = [CIFilter filterWithName:@"CIAreaAverage" withInputParameters:@{kCIInputImageKey: inputImage, kCIInputExtentKey: [CIVector vectorWithCGRect:inputImage.extent]}];
    CIImage *outputImage = filter.outputImage;

    UInt8 bitmap[4];
    CIContext *context = [CIContext contextWithOptions:@{kCIContextWorkingColorSpace: [NSNull null]}];
    CGRect bounds  = CGRectMake(0, 0, 1, 1);
    [context render:outputImage toBitmap:&bitmap rowBytes:4 bounds:bounds format:kCIFormatRGBA8 colorSpace:nil];
    return [UIColor colorWithRed:bitmap[0] / 255.0 green:bitmap[1] / 255.0 blue:bitmap[2] / 255.0 alpha:bitmap[3] / 255.0];
}

- (void)_analyzeImage:(UIImage *)image completion:(NUAImageColorCacheCompletion)completion {
    dispatch_async(_processingQueue, ^{
        // Create entry
        UIColor *primaryColor = [self _averageColorForImage:image];
        UIColor *accentColor = primaryColor.accentColor;

        NUAImageColorInfo *entry = [NUAImageColorInfo colorInfoWithPrimaryColor:primaryColor accentColor:accentColor];

        // Completion
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(entry);
        });
    });
}

#pragma mark - Cache Management

- (BOOL)hasColorDataForImage:(UIImage *)image type:(NUAImageColorInfoType)type {
    return [self cachedColorInfoForImage:image type:type] != nil;
}

- (NUAImageColorInfo *)cachedColorInfoForImage:(UIImage *)image type:(NUAImageColorInfoType)type {
    // Type determines what cache we use
    switch (type) {
        case NUAImageColorInfoTypeAppIcon:
           return [self.iconCache objectForKey:image];
        case NUAImageColorInfoTypeAlbumArtwork:
            return [self.albumArtworkCache objectForKey:image];
    }
}

- (void)cacheColorInfoForImage:(UIImage *)image type:(NUAImageColorInfoType)type completion:(NUAImageColorCacheCompletion)completion {
    // Dispatch on our queue
    [self _analyzeImage:image completion:^(NUAImageColorInfo *colorInfo) {
        // Type determines what cache we add to
        switch (type) {
            case NUAImageColorInfoTypeAppIcon:
                [self.iconCache setObject:colorInfo forKey:image];
                break;
            case NUAImageColorInfoTypeAlbumArtwork:
                [self.albumArtworkCache setObject:colorInfo forKey:image];
                break;
        }

        // Call completion
        completion(colorInfo);
    }];
}

#pragma mark - Non-Caching Methods

- (void)queryColorInfoForImage:(UIImage *)image completion:(NUAImageColorCacheCompletion)completion {
    // Simply call our helper method
    [self _analyzeImage:image completion:completion];
}

@end