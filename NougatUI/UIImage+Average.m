#import "UIImage+Average.h"

@implementation UIImage (Average)

- (UIColor *)averageColor {
    CIImage *inputImage = self.CIImage ?: [CIImage imageWithCGImage:self.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIAreaAverage" withInputParameters:@{kCIInputImageKey: inputImage, kCIInputExtentKey: [CIVector vectorWithCGRect:inputImage.extent]}];
    CIImage *outputImage = filter.outputImage;

    UInt8 bitmap[4];
    // *** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '*** -[__NSPlaceholderDictionary initWithObjects:forKeys:count:]: attempt to insert nil object from objects[0]'
    CIContext *context = [CIContext contextWithOptions:@{kCIContextWorkingColorSpace: [NSNull null]}];
    CGRect bounds  = CGRectMake(0, 0, 1, 1);
    [context render:outputImage toBitmap:&bitmap rowBytes:4 bounds:bounds format:kCIFormatRGBA8 colorSpace:nil];
    return [UIColor colorWithRed:bitmap[0] / 255.0 green:bitmap[1] / 255.0 blue:bitmap[2] / 255.0 alpha:bitmap[3] / 255.0];
}

@end