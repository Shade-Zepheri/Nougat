#import "NUARootListController.h"
#import <CepheiPrefs/HBAppearanceSettings.h>

@implementation NUARootListController

#pragma mark - HBListController

+ (NSString *)hb_specifierPlist {
    return @"Root";
}

#pragma mark - Initializer

- (instancetype)init {
    self = [super init];
    if (self) {
        HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
        appearanceSettings.tintColor = [UIColor colorWithRed:0.32 green:0.18 blue:0.66 alpha:1.0];
        appearanceSettings.navigationBarTintColor = [UIColor whiteColor];
        appearanceSettings.navigationBarTitleColor = [UIColor whiteColor];
        appearanceSettings.navigationBarBackgroundColor = [UIColor colorWithRed:0.32 green:0.18 blue:0.66 alpha:1.0];
        appearanceSettings.statusBarTintColor = [UIColor whiteColor];
        appearanceSettings.translucentNavigationBar = NO;
        self.hb_appearanceSettings = appearanceSettings;
    }

    return self;
}

@end
