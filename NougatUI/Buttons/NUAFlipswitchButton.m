#import "NUAFlipswitchButton.h"
#import <Flipswitch/Flipswitch.h>

@interface NUAFlipswitchButton ()
@property (assign, nonatomic) FSSwitchState switchState;

@end

@implementation NUAFlipswitchButton

#pragma mark - Initialization

- (instancetype)initWithSwitchIdentifier:(NSString *)identifier {
    self = [super init];
    if (self) {
        // Set defaults
        _switchIdentifier = identifier;
        _switchState = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:identifier];

        // Register for notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchesChangedState:) name:FSSwitchPanelSwitchStateChangedNotification object:nil];
    }

    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; switchIdentifier = %@>", self.class, self, self.switchIdentifier];
}

#pragma mark - Properties

- (BOOL)isSelected {
    // Override to use flipswitch state
    if (self.inverted) {
        switch (self.switchState) {
            case FSSwitchStateOff:
                return YES;
            case FSSwitchStateIndeterminate:
            case FSSwitchStateOn:
                return NO;
        }
    } else {
        switch (self.switchState) {
            case FSSwitchStateIndeterminate:
            case FSSwitchStateOff:
                return NO;
            case FSSwitchStateOn:
                return YES;
        }
    }
}

- (void)setSelected:(BOOL)selected {
    // Determine state
    FSSwitchState newState = selected ? (self.inverted ? FSSwitchStateOff : FSSwitchStateOn) : (self.inverted ? FSSwitchStateOn : FSSwitchStateOff);

    // Set flipswitch state
    FSSwitchPanel *switchPanel = [FSSwitchPanel sharedPanel];

    self.switchState = [switchPanel stateForSwitchIdentifier:self.switchIdentifier];
    [switchPanel setState:newState forSwitchIdentifier:self.switchIdentifier];
}

#pragma mark - Notifications

- (void)switchesChangedState:(NSNotification *)notification {
    NSString *changedSwitch = notification.userInfo[FSSwitchPanelSwitchIdentifierKey];
    if (changedSwitch && ![changedSwitch isEqualToString:self.switchIdentifier]) {
        return;
    }

    // Update state and refresh
    self.switchState = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:self.switchIdentifier];
    [self refreshAppearance];
}

@end