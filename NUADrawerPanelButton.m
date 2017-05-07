#import "NUADrawerPanelButton.h"

@implementation NUADrawerPanelButton

- (instancetype)initWithFrame:(CGRect)frame withType:(NUAToggleType)type {
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleWasTapped:)];
        [self addGestureRecognizer:tapGesture];

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

    switch (self.toggleType) {
      case NUAToggleTypeAirplaneMode:
          break;
      case NUAToggleTypeWifi:
          break;
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
