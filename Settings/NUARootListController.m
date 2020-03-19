#import "NUARootListController.h"
#import "PSSegmentTableCell+Enable.h"
#import <Cephei/HBPreferences.h>
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <CepheiPrefs/HBSupportController.h>
#import <Preferences/PSSpecifier.h>
#import <TechSupport/TSContactViewController.h>
#import <UIKit/UIImage+Private.h>
#import <version.h>

@interface NUARootListController ()
@property (strong, readonly, nonatomic) HBPreferences *preferences;

@end

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
        _preferences = [HBPreferences preferencesForIdentifier:@"com.shade.nougat"];

        // Set appearance
        HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
        appearanceSettings.tintColor = [UIColor colorWithRed:0.04 green:0.28 blue:0.42 alpha:1.0];
        appearanceSettings.translucentNavigationBar = NO;
        appearanceSettings.tableViewCellSeparatorColor = [UIColor clearColor];
        appearanceSettings.largeTitleStyle = HBAppearanceSettingsLargeTitleStyleNever;
        self.hb_appearanceSettings = appearanceSettings;

        // Disable large title
        if (@available(iOS 11, *)) {
            // iOS 11 only
            self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
        }
    }

    return self;
}

#pragma mark - Specifiers

- (BOOL)_hasColorflowInstalled {
    // Check stuffs once
    static BOOL installed = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        BOOL hasColorflow3 = [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/ColorFlow3.dylib"];
        BOOL hasColorflow4 = [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/ColorFlow4.dylib"];
        BOOL hasColorflow5 = [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/ColorFlow5.dylib"];
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

- (void)_modifySpecifierVisibility {
    // Remove specifiers
    if (![self _hasColorflowInstalled]) {
        // Colorflow not installed
        [self removeSpecifierID:@"ColorflowCell"];
    }

    if (![self _systemDarkmodeAvailable]) {
        // Not iOS 13
        [self removeSpecifierID:@"SystemAppearanceCell"];
    } else {
        // Disable segment controller if using system appearance
        PSSpecifier *segmentControlSpecifier = [self specifierForID:@"AppearanceSettingCell"];
        PSSegmentTableCell *segmentControlCell = (PSSegmentTableCell *)[self cachedCellForSpecifier:segmentControlSpecifier];
        if (segmentControlCell.cellEnabled != ![self.preferences boolForKey:@"usesSystemAppearance"]) {
            segmentControlCell.cellEnabled = ![self.preferences boolForKey:@"usesSystemAppearance"];

            // Reload change
            [self reloadSpecifier:segmentControlSpecifier animated:YES];
        }
    }
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
    self.headerImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.headerImageView.image = [UIImage imageNamed:@"Header" inBundle:self.bundle];
    self.headerImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [headerContainerView addSubview:self.headerImageView];

    // Constraint up
    [self.headerImageView.topAnchor constraintEqualToAnchor:headerContainerView.topAnchor].active = YES;
    [self.headerImageView.leadingAnchor constraintEqualToAnchor:headerContainerView.leadingAnchor].active = YES;
    [self.headerImageView.trailingAnchor constraintEqualToAnchor:headerContainerView.trailingAnchor].active = YES;
    [self.headerImageView.bottomAnchor constraintEqualToAnchor:headerContainerView.bottomAnchor].active = YES;

    self.table.tableHeaderView = headerContainerView;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Update image offset
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY > 0) {
        offsetY = 0;
    }

    self.headerImageView.frame = CGRectMake(0, offsetY, CGRectGetWidth(self.table.bounds), 200 - offsetY);
}

#pragma mark - Support

- (void)showSupportEmailController {
    TSContactViewController *supportController = [HBSupportController supportViewControllerForBundle:[NSBundle bundleForClass:self.class] preferencesIdentifier:@"com.shade.nougat"];
    [self.navigationController pushViewController:supportController animated:YES];
}

@end
