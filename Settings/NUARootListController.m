#import "NUARootListController.h"
#import "PSSegmentTableCell+Enable.h"
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <CepheiPrefs/HBSupportController.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import <Preferences/Preferences.h>
#import <TechSupport/TSContactViewController.h>
#import <UIKit/UIKit+Private.h>
#import <UIKit/UIImage+Private.h>
#import <version.h>

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
        // Set preferences
        _preferences = [NUAPreferenceManager sharedSettings];

        // Set appearance
        HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
        appearanceSettings.tintColor = [UIColor colorWithRed:0.04 green:0.28 blue:0.42 alpha:1.0];
        appearanceSettings.tableViewCellSeparatorColor = [UIColor clearColor];
        self.hb_appearanceSettings = appearanceSettings;

        // Disable large title (iOS 11 only)
        if (@available(iOS 11, *)) {
            self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
        }
    }

    return self;
}

#pragma mark - Specifiers

- (void)_modifySpecifierVisibility {
    // Remove specifiers
    if (![self _hasColorflowInstalled]) {
        // Colorflow not installed
        [self removeSpecifierID:@"ColorflowCell"];
    }

    if (![self _systemDarkmodeAvailable]) {
        // Not iOS 13
        [self removeSpecifierID:@"SystemAppearanceCell"];
    }

    // Enable/Disable segment control
    BOOL enabled = self.preferences.usesSystemAppearance;
    [self _modifySegmentCellVisibility:!enabled];
}

- (void)_modifySegmentCellVisibility:(BOOL)enabled {
    // Get specifier
    PSSpecifier *segmentControlSpecifier = [self specifierForID:@"AppearanceSettingCell"];
    if (!segmentControlSpecifier) {
        return;
    }

    // Set disabled
    segmentControlSpecifier.properties[PSEnabledKey] = @(enabled);
}

- (void)reloadSpecifiers {
	[super reloadSpecifiers];
	[self _modifySpecifierVisibility];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Specifiers
    [self _modifySpecifierVisibility];

    // Create header view
    UIView *headerContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 200)];
    UIImage *headerImage = [UIImage imageNamed:@"Header" inBundle:self.bundle];
    self.headerImageView = [[UIImageView alloc] initWithImage:headerImage];
    self.headerImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.headerImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [headerContainerView addSubview:self.headerImageView];

    // Corner radius up on iPad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.headerImageView.clipsToBounds = YES;
        self.headerImageView._continuousCornerRadius = 10.0;
    }

    // Constraint up
    [self.headerImageView.centerXAnchor constraintEqualToAnchor:headerContainerView.centerXAnchor].active = YES;
    [self.headerImageView.centerYAnchor constraintEqualToAnchor:headerContainerView.centerYAnchor].active = YES;
    [self.headerImageView.widthAnchor constraintEqualToConstant:headerImage.size.width].active = YES;
    [self.headerImageView.heightAnchor constraintEqualToConstant:headerImage.size.height].active = YES;

    self.table.tableHeaderView = headerContainerView;
}

#pragma mark - Support

- (void)showSupportEmailController {
    TSContactViewController *supportController = [HBSupportController supportViewControllerForBundle:[NSBundle bundleForClass:self.class] preferencesIdentifier:@"com.shade.nougat"];
    [self.navigationController pushViewController:supportController animated:YES];
}

#pragma mark - Preference Values

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    PSSpecifier *appearanceSpecifier = [self specifierForID:@"SystemAppearanceCell"];
    if (appearanceSpecifier) {
        if ([specifier isEqualToSpecifier:appearanceSpecifier]) {
            // Get enabled/disabled
            PSSwitchTableCell *switchCell = (PSSwitchTableCell *)[self cachedCellForSpecifier:appearanceSpecifier];
            BOOL enabled = [switchCell controlValue].boolValue;

            // Set cell to disabled
            [self _modifySegmentCellVisibility:!enabled];
            [self reloadSpecifierID:@"AppearanceSettingCell" animated:YES];
        }
    }

	[super setPreferenceValue:value specifier:specifier];
}

#pragma mark - Helper Methods

- (BOOL)_hasColorflowInstalled {
    // Check stuffs once
    static BOOL installed = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL hasColorflow3 = [fileManager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/ColorFlow3.dylib"];
        BOOL hasColorflow4 = [fileManager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/ColorFlow4.dylib"];
        BOOL hasColorflow5 = [fileManager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/ColorFlow5.dylib"];
        installed = hasColorflow3 || hasColorflow4 || hasColorflow5;
    });

    return installed;
}

- (BOOL)_systemDarkmodeAvailable {
    // Check stuffs once
    static BOOL available = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        available = IS_IOS_OR_NEWER(iOS_13_0);
    });

    return available;
}

@end
