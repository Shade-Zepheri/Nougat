#import "NUAMainToggleButton.h"
#import <Flipswitch/Flipswitch.h>

@implementation NUAMainToggleButton

- (instancetype)initWithFrame:(CGRect)frame andSwitchIdentifier:(NSString*)identifier {
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleWasTapped:)];
        [self addGestureRecognizer:tapGesture];

        self.switchIdentifier = [NSString stringWithFormat:@"com.a3tweaks.switch.%@", identifier];

        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        self.imageView.center = CGPointMake(frame.size.width / 2, frame.size.height / 2);

        FSSwitchState state = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:self.switchIdentifier];
        _imageBundle = [NSBundle bundleWithPath:@"/var/mobile/Library/Nougat-Resources.bundle"];
        NSString *imageName = [NSString stringWithFormat:@"%@-%@", identifier, state == FSSwitchStateOff ? @"off" : @"on"];
        self.imageView.image = [UIImage imageWithContentsOfFile:[_imageBundle pathForResource:imageName ofType:@"png"]];

        [self addSubview:self.imageView];

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(switchesChangedState:) name:FSSwitchPanelSwitchStateChangedNotification object:nil];
    }

    return self;
}

- (void)toggleWasTapped:(UITapGestureRecognizer*)recognizer {
    NSString *switchIdentifier = self.switchIdentifier;
    FSSwitchPanel *switchPanel = [FSSwitchPanel sharedPanel];

    FSSwitchState state = [switchPanel stateForSwitchIdentifier:switchIdentifier];
    //cuz off means on and on means off?
    [switchPanel setState:state == FSSwitchStateOff ? FSSwitchStateOff : FSSwitchStateOn forSwitchIdentifier:switchIdentifier];
    [switchPanel applyActionForSwitchIdentifier:switchIdentifier];
}

- (void)switchesChangedState:(NSNotification *)note {
    FSSwitchState state = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:self.switchIdentifier];
    NSString *imageName = [NSString stringWithFormat:@"%@-%@", [self.switchIdentifier substringFromIndex:20], state == FSSwitchStateOff ? @"off" : @"on"];
    self.imageView.image = [UIImage imageWithContentsOfFile:[_imageBundle pathForResource:imageName ofType:@"png"]];
}

@end
