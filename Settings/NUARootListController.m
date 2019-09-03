#import "NUARootListController.h"
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <CepheiPrefs/HBSupportController.h>
#import <Preferences/PSSpecifier.h>
#import <TechSupport/TSContactViewController.h>
#import <UIKit/UIImage+Private.h>

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
        appearanceSettings.tintColor = [UIColor colorWithRed:0.04 green:0.28 blue:0.42 alpha:1.0];
        appearanceSettings.translucentNavigationBar = NO;
        appearanceSettings.tableViewCellSeparatorColor = [UIColor clearColor];

        self.hb_appearanceSettings = appearanceSettings;
    }

    return self;
}

#pragma mark - Specifiers

- (BOOL)_hasColorflowInstalled {
    // Check stuffs once
    static BOOL installed = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        BOOL colorflow3 = [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/ColorFlow3.dylib"];
        BOOL colorflow4 = [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/ColorFlow4.dylib"];
        installed = colorflow3 | colorflow4;
    });

    return installed;
}

- (void)_configureColorflowSpecifier {
    if ([self _hasColorflowInstalled]) {
        // Colorflow installed
        return;
    }

    [self removeSpecifierID:@"ColorflowCell"];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Specifiers
    [self _configureColorflowSpecifier];

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

- (void)reloadSpecifiers {
	[super reloadSpecifiers];
	[self _configureColorflowSpecifier];
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
