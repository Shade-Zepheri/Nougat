#import "NUABatteryView.h"
#import <NougatServices/NougatServices.h>
#import <UIKit/UIImage+Private.h>

@implementation NUABatteryView

- (instancetype)initWithFrame:(CGRect)frame andPercent:(CGFloat)percent {
    self = [super initWithFrame:frame];
    if (self) {
        // View Constraints
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self.widthAnchor constraintEqualToConstant:25.0].active = YES;

        _batteryImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self _updateImageForPercent:percent];
        [self addSubview:self.batteryImageView];

        // Fill constraint
        self.batteryImageView.translatesAutoresizingMaskIntoConstraints = NO;

        [self.batteryImageView.topAnchor constraintEqualToAnchor:self.topAnchor constant:15.0].active = YES;
        [self.batteryImageView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-15.0].active = YES;
        [self.batteryImageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
        [self.batteryImageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    }

    return self;
}

#pragma mark - Properties

- (void)setCurrentPercent:(CGFloat)currentPercent {
    _currentPercent = currentPercent;

    [self _updateImageForPercent:currentPercent];
}

- (void)setCharging:(BOOL)isCharging {
    _charging = isCharging;

    // Force update view
    [self _updateImageForPercent:self.currentPercent];
}

#pragma mark - Image management

- (NSString *)_imageNameForPercent:(CGFloat)percent {
    NSString *name = @"battery-";
    if (percent == 100.0) {
        // Full
        name = [name stringByAppendingString:@"full-"];
    } else if (percent < 100.0 && percent >= 90) {
        // 90
        name = [name stringByAppendingString:@"90-"];
    } else if (percent < 90.0 && percent >= 80.0) {
        // 80
        name = [name stringByAppendingString:@"80-"];
    } else if (percent < 80.0 && percent >= 60.0) {
        // 60
        name = [name stringByAppendingString:@"60-"];
    } else if (percent < 60.0 && percent >= 50.0) {
        // 50
        name = [name stringByAppendingString:@"50-"];
    } else if (percent < 50.0 && percent >= 30.0) {
        // 30
        name = [name stringByAppendingString:@"30-"];
    } else if (percent < 30.0) {
        // 20
        name = [name stringByAppendingString:@"20-"];
    }

    NSString *imageStyle = [NUAPreferenceManager sharedSettings].usingDark ? @"dark" : @"light";
    name = [name stringByAppendingString:imageStyle];

    if (self.charging) {
        name = [name stringByAppendingString:@"-charging"];
    }

    return name;
}

- (void)_updateImageForPercent:(CGFloat)percent {
    NSString *imageName = [self _imageNameForPercent:percent];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UIImage *image = [UIImage imageNamed:imageName inBundle:bundle];
    self.batteryImageView.image = image;
}

@end