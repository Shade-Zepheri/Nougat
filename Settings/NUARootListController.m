#import "NUARootListController.h"
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <CepheiPrefs/HBSupportController.h>
#import <TechSupport/TSContactViewController.h>

@implementation NUARootListController

#pragma mark - HBListController

+ (NSString *)hb_shareText {
	return [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"SHARE_TEXT", @"Root", [NSBundle bundleForClass:self], @"Default text for sharing the tweak. %@ is the device type (ie, iPhone)."), [UIDevice currentDevice].localizedModel];
}

+ (NSURL *)hb_shareURL {
    return [NSURL URLWithString:@"https://shade-zepheri.github.io/"];
}

+ (NSString *)hb_specifierPlist {
    return @"Root";
}

#pragma mark - Initializer

- (instancetype)init {
    self = [super init];
    if (self) {
        HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
        appearanceSettings.tintColor = [UIColor colorWithRed:0.31 green:0.51 blue:0.89 alpha:1.0];
        appearanceSettings.navigationBarTintColor = [UIColor blackColor];
        appearanceSettings.navigationBarBackgroundColor = [UIColor colorWithRed:0.31 green:0.51 blue:0.89 alpha:1.0];
        appearanceSettings.statusBarTintColor = [UIColor blackColor];
        appearanceSettings.translucentNavigationBar = NO;

        appearanceSettings.tableViewBackgroundColor = [UIColor colorWithRed:0.54 green:0.69 blue:0.98 alpha:1.0];
        appearanceSettings.tableViewCellTextColor = [UIColor blackColor];
        appearanceSettings.tableViewCellBackgroundColor = [UIColor colorWithRed:0.74 green:0.89 blue:1.00 alpha:1.0];
        appearanceSettings.tableViewCellSeparatorColor = [UIColor clearColor];

        self.hb_appearanceSettings = appearanceSettings;
    }

    return self;
}

#pragma mark - Support

- (void)showSupportEmailController {
    TSContactViewController *supportController = [HBSupportController supportViewControllerForBundle:[NSBundle bundleForClass:self.class] preferencesIdentifier:@"com.shade.nougat"];
    [self.navigationController pushViewController:supportController animated:YES];
}

@end
