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
        _toggleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetHeight(frame) - 20, CGRectGetHeight(frame) - 20, 14)];
        self.toggleLabel.font = [UIFont systemFontOfSize:12];
        self.toggleLabel.textColor = [UIColor whiteColor];
        self.toggleLabel.backgroundColor = [UIColor clearColor];
        self.toggleLabel.textAlignment = NSTextAlignmentCenter;

        NSString *labelText = [self.resourceBundle localizedStringForKey:identifier value:identifier table:nil];
        if ([identifier isEqualToString:@"wifi"]) {
            self.toggleLabel.text = [NUAPreferenceManager currentWifiSSID] ?: labelText;
        } else if ([identifier isEqualToString:@"cellular-data"]) {
            self.toggleLabel.text = [NUAPreferenceManager carrierName] ?: labelText;
        } else {
            self.toggleLabel.text = labelText;
        }

        [self addSubview:self.toggleLabel];
    }

    return self;
}

- (void)switchesChangedState:(NSNotification *)notification {
    [super switchesChangedState:notification];

    if ([self.switchIdentifier isEqualToString:@"wifi"]) {
        NSString *labelText = [self.resourceBundle localizedStringForKey:self.switchIdentifier value:self.switchIdentifier table:nil];
        self.toggleLabel.text = [NUAPreferenceManager currentWifiSSID] ?: labelText;
    }
}

@end
