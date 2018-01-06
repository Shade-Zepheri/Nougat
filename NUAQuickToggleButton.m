#import "NUAQuickToggleButton.h"
#import <Flipswitch/Flipswitch.h>

@implementation NUAQuickToggleButton

- (instancetype)initWithFrame:(CGRect)frame andSwitchIdentifier:(NSString *)identifier {
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleWasTapped:)];
        [self addGestureRecognizer:tapGesture];

        self.switchIdentifier = [NSString stringWithFormat:@"com.a3tweaks.switch.%@", identifier];

        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        self.imageView.center = CGPointMake(frame.size.width / 2, frame.size.height / 2);

        FSSwitchState state = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:self.switchIdentifier];
        _imageBundle = [NSBundle bundleWithPath:@"/var/mobile/Library/Nougat-Resources.bundle"];
        NSString *imageName = [NSString stringWithFormat:@"%@-%@", identifier, state == FSSwitchStateOff ? @"off" : @"on"];
        self.imageView.image = [UIImage imageNamed:imageName inBundle:_imageBundle compatibleWithTraitCollection:nil];

        [self addSubview:self.imageView];

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(switchesChangedState:) name:FSSwitchPanelSwitchStateChangedNotification object:nil];
    }

    return self;
}

- (void)toggleWasTapped:(UITapGestureRecognizer *)recognizer {
    FSSwitchPanel *switchPanel = [FSSwitchPanel sharedPanel];

    FSSwitchState state = [switchPanel stateForSwitchIdentifier:self.switchIdentifier];
    [switchPanel setState:state == FSSwitchStateOff ? FSSwitchStateOn : FSSwitchStateOff forSwitchIdentifier:self.switchIdentifier];
}

- (void)switchesChangedState:(NSNotification *)notification {
    NSString *changedSwitch = [notification.userInfo objectForKey:FSSwitchPanelSwitchIdentifierKey];
    if (![changedSwitch isEqualToString:_switchIdentifier] && changedSwitch) {
        return;
    }

    FSSwitchState state = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:self.switchIdentifier];
    NSString *imageName = [NSString stringWithFormat:@"%@-%@", [self.switchIdentifier substringFromIndex:20], state == FSSwitchStateOff ? @"off" : @"on"];
    self.imageView.image = [UIImage imageNamed:imageName inBundle:_imageBundle compatibleWithTraitCollection:nil];
}

@end
