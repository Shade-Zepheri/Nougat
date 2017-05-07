#import "NUADrawerPanelButton.h"
#import <Flipswitch/Flipswitch.h>

@implementation NUADrawerPanelButton

- (instancetype)initWithFrame:(CGRect)frame andSwitchIdentifier:(NSString*)identifier {
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleWasTapped:)];
        [self addGestureRecognizer:tapGesture];

        self.switchIdentifier = [NSString stringWithFormat:@"com.a3tweaks.switch.%@", identifier];

        if ([identifier isEqualToString:@"wifi"]) {
          self.backgroundColor = [UIColor blueColor];
        } else {
          self.backgroundColor = [UIColor greenColor];
        }
    }

    return self;
}

- (void)toggleSwitch:(BOOL)value {
    NSString *switchIdentifier = self.switchIdentifier;
    HBLogDebug(@"%@", switchIdentifier);

    FSSwitchPanel *switchPanel = [FSSwitchPanel sharedPanel];
    [switchPanel setState:value ? FSSwitchStateOn : FSSwitchStateOff forSwitchIdentifier:switchIdentifier];
    [switchPanel applyActionForSwitchIdentifier:switchIdentifier];
}

- (void)toggleWasTapped:(UITapGestureRecognizer*)recognizer {
    if (_toggled) {
        [self toggleSwitch:NO];
        _toggled = NO;
    } else {
        [self toggleSwitch:YES];
        _toggled = YES;
    }
}

@end
