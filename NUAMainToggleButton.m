#import "headers.h"
#import "NUAMainToggleButton.h"
#import "NUAPreferenceManager.h"
#import <Flipswitch/Flipswitch.h>

@implementation NUAMainToggleButton

- (instancetype)initWithFrame:(CGRect)frame andSwitchIdentifier:(NSString *)identifier {
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *array = @[@"wifi", @"cellular-data", @"bluetooth", @"do-not-disturb"];
        if ([array containsObject:identifier]) {
            //Only these toggles have an underline in Nougat;
            UIView *underline = [[UIView alloc] initWithFrame:CGRectMake(15, frame.size.height - 30, frame.size.width - 30, 1)];
            underline.backgroundColor = NougatLabelColor;
            [self addSubview:underline];
        }

        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleWasTapped:)];
        [self addGestureRecognizer:tapGesture];

        self.resourceBundle = [NSBundle bundleWithPath:@"/var/mobile/Library/Nougat-Resources.bundle"];
        _switchIdentifier = [NSString stringWithFormat:@"com.a3tweaks.switch.%@", identifier];

        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        self.imageView.center = CGPointMake(frame.size.width / 2, frame.size.height / 2.5);

        self.toggleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, frame.size.height - 20, frame.size.width - 20, 12)];
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

        FSSwitchState state = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:_switchIdentifier];
        NSString *imageName = [NSString stringWithFormat:@"%@-%@", identifier, state == FSSwitchStateOff ? @"off" : @"on"];
        self.imageView.image = [UIImage imageNamed:imageName inBundle:self.resourceBundle compatibleWithTraitCollection:nil];

        [self addSubview:self.imageView];

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(switchesChangedState:) name:FSSwitchPanelSwitchStateChangedNotification object:nil];
    }

    return self;
}

- (void)toggleWasTapped:(UITapGestureRecognizer *)recognizer {
    FSSwitchPanel *switchPanel = [FSSwitchPanel sharedPanel];

    FSSwitchState state = [switchPanel stateForSwitchIdentifier:_switchIdentifier];
    [switchPanel setState:state == FSSwitchStateOff ? FSSwitchStateOn : FSSwitchStateOff forSwitchIdentifier:_switchIdentifier];
}

- (void)switchesChangedState:(NSNotification *)notification {
    NSString *changedSwitch = [notification.userInfo objectForKey:FSSwitchPanelSwitchIdentifierKey];
    if (![changedSwitch isEqualToString:_switchIdentifier] && changedSwitch) {
        return;
    }

    FSSwitchState state = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:_switchIdentifier];
    NSString *imageName = [NSString stringWithFormat:@"%@-%@", [_switchIdentifier substringFromIndex:20], state == FSSwitchStateOff ? @"off" : @"on"];
    self.imageView.image = [UIImage imageNamed:imageName inBundle:self.resourceBundle compatibleWithTraitCollection:nil];

    if ([_switchIdentifier isEqualToString:@"wifi"]) {
        self.toggleLabel.text = ![NUAPreferenceManager currentWifiSSID] ? @"Wi-Fi" : [NUAPreferenceManager currentWifiSSID];
    }
}

@end
