#import "NUADrawerPanelButton.h"
#import <Flipswitch/Flipswitch.h>

@implementation NUADrawerPanelButton

- (instancetype)initWithFrame:(CGRect)frame withType:(NUAToggleType)type {
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleWasTapped:)];
        [self addGestureRecognizer:tapGesture];

        if (type == NUAToggleTypeWifi) {
            self.backgroundColor = [UIColor redColor];
        }

        _toggleType = type;
    }

    return self;
}

- (void)toggleWasTapped:(UITapGestureRecognizer*)recognizer {
    if (_toggled) {
        _toggled = NO;
    } else {
        _toggled = YES;
    }

    FSSwitchPanel *switchPanel = [FSSwitchPanel sharedPanel];
    switch (self.toggleType) {
      case NUAToggleTypeAirplaneMode:
          break;
      case NUAToggleTypeWifi: {
          NSString *switchIdentifier = @"com.a3tweaks.switch.wifi";
          [switchPanel setState:_toggled ? FSSwitchStateOn : FSSwitchStateOff forSwitchIdentifier:switchIdentifier];
          [switchPanel applyActionForSwitchIdentifier:switchIdentifier];
          break;
      }
      case NUAToggleTypeCellularData:
          break;
      case NUAToggleTypeTorch:
          break;
      case NUAToggleTypeRotationLock:
          break;
      case NUAToggleTypeBattery:
          break;
      case NUAToggleTypeBluetooth:
          break;
      case NUAToggleTypeDoNotDisturb:
          break;
      case NUAToggleTypeLocation:
          break;
    }
}

@end
