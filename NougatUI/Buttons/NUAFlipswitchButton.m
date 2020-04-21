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
        self.switchState = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:identifier];

        // Register for notifications
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(switchesChangedState:) name:FSSwitchPanelSwitchStateChangedNotification object:nil];
    }

    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; switchIdentifier = %@>", self.class, self, self.switchIdentifier];
}

#pragma mark - Properties

- (BOOL)isSelected {
    // Override to use flipswitch state
	return self.switchState == FSSwitchStateOn;
}

- (void)setSelected:(BOOL)selected {
    // Set flipswitch state
    FSSwitchPanel *switchPanel = [FSSwitchPanel sharedPanel];

    self.switchState = [switchPanel stateForSwitchIdentifier:self.switchIdentifier];
    [switchPanel setState:(selected) ? FSSwitchStateOn : FSSwitchStateOff forSwitchIdentifier:self.switchIdentifier];
}

#pragma mark - Notifications

- (void)switchesChangedState:(NSNotification *)notification {
    NSString *changedSwitch = notification.userInfo[FSSwitchPanelSwitchIdentifierKey];
    if (changedSwitch && ![changedSwitch isEqualToString:self.switchIdentifier]) {
        return;
    }

    // Update state and refresh
    self.switchState = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:self.switchIdentifier];
    [self refreshImage];
}

@end