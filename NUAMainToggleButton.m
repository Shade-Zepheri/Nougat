#import "headers.h"
#import "NUAMainToggleButton.h"
#import "NUAPreferenceManager.h"
#import <Flipswitch/Flipswitch.h>

@implementation NUAMainToggleButton

+ (CGSize)imageSize {
    return CGSizeMake(32, 32);
}

- (instancetype)initWithFrame:(CGRect)frame andSwitchIdentifier:(NSString *)identifier {
    self = [super initWithFrame:frame andSwitchIdentifier:identifier];
    if (self) {
        NSArray *array = @[@"wifi", @"cellular-data", @"bluetooth", @"do-not-disturb"];
        if ([array containsObject:identifier]) {
            //Only these toggles have an underline in Nougat;
            UIView *underline = [[UIView alloc] initWithFrame:CGRectMake(15, frame.size.height - 30, frame.size.width - 30, 1)];
            underline.backgroundColor = NougatLabelColor;
            [self addSubview:underline];
        }

        self.imageView.center = CGPointMake(frame.size.width / 2, frame.size.height / 2.5);

        _toggleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, frame.size.height - 20, frame.size.width - 20, 12)];
        self.toggleLabel.font = [UIFont systemFontOfSize:12];
        self.toggleLabel.textColor = [UIColor whiteColor];
        self.toggleLabel.backgroundColor = [UIColor clearColor];
        self.toggleLabel.textAlignment = NSTextAlignmentCenter;
        if ([identifier isEqualToString:@"wifi"]) {
            self.toggleLabel.text = ![NUAPreferenceManager currentWifiSSID] ? @"Wi-Fi" : [NUAPreferenceManager currentWifiSSID];
        } else {
            self.toggleLabel.text = [self.resourceBundle localizedStringForKey:identifier value:identifier table:nil];
        }
        [self addSubview:self.toggleLabel];
    }

    return self;
}

- (void)switchesChangedState:(NSNotification *)notification {
    [super switchesChangedState:notification];

    if ([self.switchIdentifier isEqualToString:@"wifi"]) {
        self.toggleLabel.text = ![NUAPreferenceManager currentWifiSSID] ? @"Wi-Fi" : [NUAPreferenceManager currentWifiSSID];
    }
}

@end
