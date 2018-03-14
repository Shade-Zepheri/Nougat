#import "NUAQuickToggleButton.h"

@implementation NUAQuickToggleButton

+ (CGSize)imageSize {
    return CGSizeMake(28, 28);
}

- (instancetype)initWithFrame:(CGRect)frame andSwitchIdentifier:(NSString *)identifier {
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleWasTapped:)];
        [self addGestureRecognizer:tapGesture];

        _switchIdentifier = [NSString stringWithFormat:@"com.a3tweaks.switch.%@", identifier];

        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [self.class imageSize].width, [self.class imageSize].height)];
        self.imageView.center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));

        _state = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:self.switchIdentifier];
        _resourceBundle = [NSBundle bundleWithPath:@"/var/mobile/Library/Nougat-Resources.bundle"];

        NSString *imageName = [NSString stringWithFormat:@"%@-%@", identifier, (self.state == FSSwitchStateOff) ? @"off" : @"on"];
        self.imageView.image = [UIImage imageNamed:imageName inBundle:_resourceBundle compatibleWithTraitCollection:nil];

        [self addSubview:self.imageView];

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(switchesChangedState:) name:FSSwitchPanelSwitchStateChangedNotification object:nil];
    }

    return self;
}

- (void)toggleWasTapped:(UITapGestureRecognizer *)recognizer {
    FSSwitchPanel *switchPanel = [FSSwitchPanel sharedPanel];

    _state = [switchPanel stateForSwitchIdentifier:self.switchIdentifier];
    [switchPanel setState:(self.state == FSSwitchStateOff) ? FSSwitchStateOn : FSSwitchStateOff forSwitchIdentifier:self.switchIdentifier];
}

- (void)switchesChangedState:(NSNotification *)notification {
    NSString *changedSwitch = [notification.userInfo objectForKey:FSSwitchPanelSwitchIdentifierKey];
    if (changedSwitch && ![changedSwitch isEqualToString:self.switchIdentifier]) {
        return;
    }

    _state = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:self.switchIdentifier];
    NSString *imageName = [NSString stringWithFormat:@"%@-%@", [self.switchIdentifier substringFromIndex:20], (self.state == FSSwitchStateOff) ? @"off" : @"on"];
    UIImage *image = [UIImage imageNamed:imageName inBundle:_resourceBundle compatibleWithTraitCollection:nil];

    // animate transition
    [UIView transitionWithView:self.imageView duration:0.2 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.imageView.image = image;
    } completion:nil];
}

@end
