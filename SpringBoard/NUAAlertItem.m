#import "NUAAlertItem.h"
#import <FrontBoardServices/FBSSystemService.h>
#import <NougatServices/NougatServices.h>
#import <Macros.h>

@implementation NUAAlertItem

#pragma mark - Initializers

+ (instancetype)userGuideAlertItem {
    return [[self alloc] init];
}

- (void)show {
    // Activate
	[SBAlertItem activateAlertItem:self];
}

#pragma mark - SBAlertItem

- (void)configure:(BOOL)configure requirePasscodeForActions:(BOOL)requirePasscode {
    [super configure:configure requirePasscodeForActions:requirePasscode];

    // Configure alert
    [self alertController].title = @"Nougat";

    NSBundle *localizationBundle = [NSBundle bundleWithIdentifier:@"com.shade.NougatUI"];
    NSString *fallbackMessage = @"It appears that this is your first time using Nougat. Do you want to go through the user guide?";
	[self alertController].message = [localizationBundle localizedStringForKey:@"USER_GUIDE_PROMPT" value:fallbackMessage table:nil];

    // Add cancel action
    __weak __typeof(self) weakself = self;
    NSString *localizedDismiss = [localizationBundle localizedStringForKey:@"DISMISS" value:@"Dismiss" table:nil];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:localizedDismiss style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // Set has seen and dismiss
        [[NUAPreferenceManager sharedSettings] setHasBeenPrompted];
        [weakself dismiss];
    }];
    [[self alertController] addAction:cancelAction];

    NSString *localizedConfirm = [localizationBundle localizedStringForKey:@"CONFIRM" value:@"OK" table:nil];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:localizedConfirm style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // Show tutorial
        NSURL *userGuideURL = [NSURL URLWithString:@"prefs:root=Nougat&path=USER_GUIDE"];
        FBSSystemService *systemService = [FBSSystemService sharedService];
        mach_port_t port = [systemService createClientPort];

        [systemService openURL:userGuideURL application:@"com.apple.Preferences" options:@{FBSOpenApplicationOptionKeyUnlockDevice: @(YES)} clientPort:port withResult:^(NSError *error) {
            if (error) {
                // Print error
                HBLogError(@"[Nougat] openURL error: %@", error);
                return;
            }

            // Set has seen user guide and dismiss
            [[NUAPreferenceManager sharedSettings] setHasBeenPrompted];
            [weakself dismiss];
        }];
    }];
    [[self alertController] addAction:confirmAction];
}

- (BOOL)allowMenuButtonDismissal {
    return NO;
}

- (BOOL)allowLockScreenDismissal {
    return NO;
}

- (BOOL)shouldShowInLockScreen {
    return NO;
}

- (BOOL)reappearsAfterUnlock {
    return YES;
}

@end