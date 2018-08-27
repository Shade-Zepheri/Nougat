#import "NUAFlipswitchToggle.h"
#import "NUAPreferenceManager.h"
#import <UIKit/UIImage+Private.h>

@implementation NUAFlipswitchToggle

+ (NSBundle *)sharedResourceBundle {
	static NSBundle *sharedResourceBundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,  ^{
    	sharedResourceBundle = [NSBundle bundleWithPath:@"/var/mobile/Library/Nougat-Resources.bundle"];
    });

    return sharedResourceBundle;
}

- (instancetype)initWithFrame:(CGRect)frame andSwitchIdentifier:(NSString *)identifier {
    self = [super initWithFrame:frame];
    if (self) {
        _resourceBundle = [self.class sharedResourceBundle];

        _displayName = [[UILabel alloc] initWithFrame:CGRectZero];
        self.displayName.translatesAutoresizingMaskIntoConstraints = NO;
        self.displayName.alpha = 0.0;
        self.displayName.font = [UIFont systemFontOfSize:12];
        self.displayName.textColor = [NUAPreferenceManager sharedSettings].textColor;
        self.displayName.backgroundColor = [UIColor clearColor];
        self.displayName.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.displayName];

        // Constraints
        [self.displayName.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
        [self.displayName.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;

        // Create imageView
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.imageView];

        // Constraints
        [self.imageView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
        [self.imageView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
        [self.imageView.widthAnchor constraintEqualToConstant:28].active = YES;
        [self.imageView.heightAnchor constraintEqualToConstant:28].active = YES;

        self.switchIdentifier = identifier;

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(switchesChangedState:) name:FSSwitchPanelSwitchStateChangedNotification object:nil];
        [center addObserver:self selector:@selector(backgroundColorDidChange:) name:@"NUANotificationShadeChangedBackgroundColor" object:nil];
    }

    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; switchIdentifier = %@>", self.class, self, self.switchIdentifier];
}

#pragma mark - Ripple

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];

    [self toggleSwitchState];
}

#pragma mark - Toggles

- (void)toggleSwitchState {
    FSSwitchPanel *switchPanel = [FSSwitchPanel sharedPanel];

    NSString *flipswitchIdentifier = [NSString stringWithFormat:@"com.a3tweaks.switch.%@", self.switchIdentifier];
    _switchState = [switchPanel stateForSwitchIdentifier:flipswitchIdentifier];
    [switchPanel setState:(self.switchState == FSSwitchStateOff) ? FSSwitchStateOn : FSSwitchStateOff forSwitchIdentifier:flipswitchIdentifier];
}

#pragma mark - Properties

- (void)setSwitchIdentifier:(NSString *)identifier {
    _switchIdentifier = identifier;

    // Update state
    NSString *flipswitchIdentifier = [NSString stringWithFormat:@"com.a3tweaks.switch.%@", identifier];
    _switchState = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:flipswitchIdentifier];

    // Update image
    [self _updateImageView:NO];

    // Update label text
    NSString *labelText = [self.resourceBundle localizedStringForKey:identifier value:identifier table:nil];
    if ([identifier isEqualToString:@"wifi"]) {
        self.displayName.text = [NUAPreferenceManager currentWifiSSID] ?: labelText;
    } else {
        self.displayName.text = labelText;
    }
}

#pragma mark - Image management

- (void)_updateImageView:(BOOL)animated {
    // Get image name
    NSString *stateString = NSStringFromFSSwitchState(self.switchState);
    NSString *imageName = [NSString stringWithFormat:@"%@_%@", self.switchIdentifier, stateString];

    // TODO: Simplify this mess
    if ([self.switchIdentifier isEqualToString:@"rotation-lock"]) {
        if (self.switchState == FSSwitchStateOff) {
            BOOL useDark = [[NUAPreferenceManager sharedSettings].textColor isEqual:[UIColor blackColor]];
            NSString *imageStyle = useDark ? @"_black" : @"_white";
            imageName = [imageName stringByAppendingString:imageStyle];
        }
    } else if (self.switchState == FSSwitchStateOn) {
        // Use dark / light image
        BOOL useDark = [[NUAPreferenceManager sharedSettings].textColor isEqual:[UIColor blackColor]];
        NSString *imageStyle = useDark ? @"_black" : @"_white";
        imageName = [imageName stringByAppendingString:imageStyle];
    } 

    // Animate transition
    CGFloat duration = animated ? 0.4 : 0.0;
    [UIView transitionWithView:self.imageView duration:duration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.imageView.image = [UIImage imageNamed:imageName inBundle:self.resourceBundle];
    } completion:nil];
}

#pragma mark - Notifications

- (void)switchesChangedState:(NSNotification *)notification {
    NSString *changedSwitch = notification.userInfo[FSSwitchPanelSwitchIdentifierKey];
    NSString *flipswitchIdentifier = [NSString stringWithFormat:@"com.a3tweaks.switch.%@", self.switchIdentifier];
    if (changedSwitch && ![changedSwitch isEqualToString:flipswitchIdentifier]) {
        return;
    }

    _switchState = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:flipswitchIdentifier];
    [self _updateImageView:YES];

    if ([self.switchIdentifier isEqualToString:@"wifi"]) {
        NSString *labelText = [self.resourceBundle localizedStringForKey:self.switchIdentifier value:self.switchIdentifier table:nil];

        // Animate change
        [UIView transitionWithView:self.displayName duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.displayName.text = [NUAPreferenceManager currentWifiSSID] ?: labelText;
        } completion:nil];
    }
}

- (void)backgroundColorDidChange:(NSNotification *)notification {
    NSDictionary<NSString *, UIColor *> *colorInfo = notification.userInfo;

    // Update label and image
    self.displayName.textColor = colorInfo[@"textColor"];
    [self _updateImageView:NO];
}

@end