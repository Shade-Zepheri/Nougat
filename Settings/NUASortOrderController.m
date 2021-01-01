#import "NUASortOrderController.h"
#import "NUAToggleDescription.h"
#import <Cephei/HBPreferences.h>
#import <UIKit/UIImage+Private.h>

@interface NUASortOrderController ()
@property (strong, nonatomic) NSMutableArray<NSString *> *enabledIdentifiers;
@property (strong, nonatomic) NSMutableArray<NSString *> *disabledIdentifiers;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NUAToggleDescription *> *identifiersToDescription;

@property (strong, nonatomic) PSSpecifier *enabledTogglesSectionSpecifier;
@property (strong, nonatomic) PSSpecifier *disabledTogglesSectionSpecifier;

@end

@implementation NUASortOrderController

#pragma mark - PSListController

- (NSMutableArray<PSSpecifier *> *)specifiers {
    if (!_specifiers) {
        NSMutableArray<PSSpecifier *> *specifiers = [self loadSpecifiersFromPlistName:@"SortOrder" target:self];

        // Add enabled toggles section
        NSBundle *bundle = [NSBundle bundleForClass:self.class];
        NSString *enabledSectionTitle = [bundle localizedStringForKey:@"ENABLED_MODULES_SECTION_TITLE" value:@"Include" table:@"SortOrder"];
        self.enabledTogglesSectionSpecifier = [PSSpecifier groupSpecifierWithName:enabledSectionTitle];
        [specifiers addObject:self.enabledTogglesSectionSpecifier];

        // Add enabled toggles
        NSMutableArray<PSSpecifier *> *enabledToggles = [self _specifiersForIdentifiers:self.enabledIdentifiers];
        [specifiers addObjectsFromArray:enabledToggles];

        // Add disabled section
        NSString *disabledSectionTitle = [bundle localizedStringForKey:@"DISABLED_MODULES_SECTION_TITLE" value:@"More Toggles" table:@"SortOrder"];
        PSSpecifier *disabledSectionSpecifier = [PSSpecifier groupSpecifierWithName:disabledSectionTitle];
        [specifiers addObject:disabledSectionSpecifier];

        // Add disabled toggles
        NSMutableArray<PSSpecifier *> *disabledToggles = [self _specifiersForIdentifiers:self.disabledIdentifiers];
        [specifiers addObjectsFromArray:disabledToggles];

        _specifiers = specifiers;
    }

    return _specifiers;
}

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        // Create arrays
        _enabledIdentifiers = [NSMutableArray array];
        _disabledIdentifiers = [NSMutableArray array];
        _identifiersToDescription = [NSMutableDictionary dictionary];

        // Set prefs
        _preferences = [NUAPreferenceManager sharedSettings];

        // Populate data
        [self _repopulateToggleData];
    }

    return self;
}

#pragma mark - Toggles

- (void)_repopulateToggleData {
    // Construct descriptions
    for (NSString *identifier in self.preferences.loadableToggleIdentifiers) {
        NUAToggleInfo *toggleInfo = [self.preferences toggleInfoForIdentifier:identifier];
        NSBundle *toggleBundle = [NSBundle bundleWithURL:toggleInfo.toggleBundleURL];

        NSString *displayName = [self _displayNameFromBundle:toggleBundle];
        UIImage *settingsIcon = [self _iconFromBundle:toggleBundle];
        NUAToggleDescription *toggleDescription = [NUAToggleDescription descriptionWithIdentifier:toggleInfo.toggleIdentifier displayName:displayName iconImage:settingsIcon];

        self.identifiersToDescription[toggleDescription.identifier] = toggleDescription;
    }

    // Set enabled list
    _enabledIdentifiers = [self.preferences.enabledToggleIdentifiers mutableCopy];

    // Get disabled list
    NSSet<NSString *> *tempEnabledSet = [NSSet setWithArray:[self.enabledIdentifiers copy]];
    NSMutableSet<NSString *> *disabledIdentifiers = [self.preferences.loadableToggleIdentifiers mutableCopy];
    [disabledIdentifiers minusSet:tempEnabledSet]; 

    // Sort by display name
    NSArray<NSString *> *currentDisabledToggles = disabledIdentifiers.allObjects;
    NSMutableArray<NSString *> *displayNamesArray = [NSMutableArray array];
    for (NSString *identifier in currentDisabledToggles) {
        NSString *displayName = [self _displayNameForIdentifier:identifier];
        NSString *sortedNameEntry = [NSString stringWithFormat:@"%@|%@", displayName, identifier];
        [displayNamesArray addObject:sortedNameEntry];
    }

    // Alphabetize
    NSArray<NSString *> *sortedDisplayName = [displayNamesArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSMutableArray<NSString *> *sortedDisabledToggles = [NSMutableArray array];
    for (NSString *entry in sortedDisplayName) {
        // Get identifier from entry
        NSArray<NSString *> *components = [entry componentsSeparatedByString:@"|"];
        [sortedDisabledToggles addObject:components[1]];
    }

    _disabledIdentifiers = sortedDisabledToggles;
}

- (NSMutableArray<PSSpecifier *> *)_specifiersForIdentifiers:(NSMutableArray<NSString *> *)identifiers {
    // Create specifiers from display names of identifiers
    NSMutableArray<PSSpecifier *> *specifiers = [NSMutableArray array];
    for (NSString *identifier in identifiers) {
        NSString *displayName = [self _displayNameForIdentifier:identifier];
        PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:displayName target:self set:NULL get:NULL detail:NULL cell:PSListItemCell edit:NULL];
        [specifiers addObject:specifier];
    }

    return specifiers;
}

#pragma mark - PSViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Set editing
    [[self table] setEditing:YES animated:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // Save settings
    [self _updateEnabledToggles];
}

#pragma mark - Helper Methods

- (NSMutableArray<NSString *> *)arrayForSection:(NSInteger)section {
    switch (section) {
        case 1:
            return self.enabledIdentifiers;
        case 2:
            return self.disabledIdentifiers;
        default:
            return nil;
    }
}

- (NSString *)_displayNameForIdentifier:(NSString *)identifier {
    return [self _descriptionForIdentifier:identifier].displayName;
}

- (NSUInteger)_indexForInsertingItemWithIdentifier:(NSString *)identifier intoArray:(NSArray<NSString *> *)array {
    return [array indexOfObject:identifier inSortedRange:NSMakeRange(0, array.count) options:NSBinarySearchingInsertionIndex usingComparator:^(NSString *id1, NSString *id2) {
        NSString *displayName1 = [self _displayNameForIdentifier:id1];
        NSString *displayName2 = [self _displayNameForIdentifier:id2];

        return [displayName1 compare:displayName2];
    }];
}

- (NSString *)_displayNameFromBundle:(NSBundle *)bundle {
    NSString *displayName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if (!displayName) {
        // Fall back to bundle name
        displayName = [bundle objectForInfoDictionaryKey:(__bridge_transfer NSString *)kCFBundleNameKey];
    }

    if (!displayName) {
        // Fall back to executable name
        displayName = [bundle objectForInfoDictionaryKey:(__bridge_transfer NSString *)kCFBundleExecutableKey];
    }

    if (!displayName) {
        // Fall back to bundle identifier
        displayName = bundle.bundleIdentifier;
    }

    return displayName;
}

- (UIImage *)_iconFromBundle:(NSBundle *)bundle {
    UIImage *settingsIcon = [UIImage imageNamed:@"SettingsIcon" inBundle:bundle];
    if (!settingsIcon) {
        // Provide fallback icon
        settingsIcon = [UIImage imageNamed:@"FallbackSettingsIcon" inBundle:[NSBundle bundleForClass:self.class]];
    }

    return settingsIcon;
}

- (NSString *)_identifierAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray<NSString *> *sectionIdentifiers = [self arrayForSection:indexPath.section];
    return sectionIdentifiers[indexPath.row];
}

- (NUAToggleDescription *)_descriptionForIdentifier:(NSString *)identifier {
    return self.identifiersToDescription[identifier];
}

- (NUAToggleDescription *)_descriptionAtIndexPath:(NSIndexPath *)indexPath {
    return [self _descriptionForIdentifier:[self _identifierAtIndexPath:indexPath]];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section != 0) {
        NUAToggleDescription *description = [self _descriptionAtIndexPath:indexPath];
        cell.imageView.image = description.iconImage;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        if (self.enabledIdentifiers.count >= 9) {
            // Dont add more than 9 toggles
            return;
        }

        // Move from disabled to enabled
        NSString *identifier = self.disabledIdentifiers[indexPath.row];
        NSUInteger insertIndex = self.enabledIdentifiers.count;
        NSUInteger disabledSectionIndex = [self indexOfSpecifier:self.disabledTogglesSectionSpecifier];

        NSUInteger specifierInsertIndex = insertIndex + [self indexOfSpecifier:self.enabledTogglesSectionSpecifier] + 1;
        PSSpecifier *specifier = [self specifierAtIndex:disabledSectionIndex + indexPath.row + 1]; 

        [self.disabledIdentifiers removeObject:identifier];
        [self.enabledIdentifiers addObject:identifier];

        // Update table
        [self beginUpdates];

        [self removeSpecifierAtIndex:disabledSectionIndex + indexPath.row + 1 animated:YES];
        [self insertSpecifier:specifier atIndex:specifierInsertIndex animated:YES];

        [self endUpdates];
    } else if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Move from enabled to disabled
        NSString *identifier = self.enabledIdentifiers[indexPath.row];
        NSUInteger insertIndex = [self _indexForInsertingItemWithIdentifier:identifier intoArray:self.disabledIdentifiers];
        NSUInteger enabledSectionIndex = [self indexOfSpecifier:self.enabledTogglesSectionSpecifier];

        NSUInteger specifierInsertIndex = [self indexOfSpecifier:self.disabledTogglesSectionSpecifier] + insertIndex;
        PSSpecifier *specifier = [self specifierAtIndex:enabledSectionIndex + indexPath.row + 1];

        [self.enabledIdentifiers removeObject:identifier];
        [self.disabledIdentifiers insertObject:identifier atIndex:insertIndex];

        // Update table
        [self beginUpdates];

        [self removeSpecifierAtIndex:enabledSectionIndex + indexPath.row + 1 animated:YES];
        [self insertSpecifier:specifier atIndex:specifierInsertIndex animated:YES];

        [self endUpdates];
    }

    [self reloadSpecifiers];
    [self _updateEnabledToggles];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section != 0);
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == 1);
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSMutableArray<NSString *> *sourceArray = [self arrayForSection:sourceIndexPath.section];
    NSMutableArray<NSString *> *destinationArray = [self arrayForSection:destinationIndexPath.section];
    NSString *identifier = sourceArray[sourceIndexPath.row];

    [sourceArray removeObjectAtIndex:sourceIndexPath.row];
    [destinationArray insertObject:identifier atIndex:destinationIndexPath.row];

    [self reloadSpecifiers];
    [self _updateEnabledToggles];
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0) {
        return NO;
    } else {
        return [super tableView:tableView shouldHighlightRowAtIndexPath:indexPath];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 1:
            return UITableViewCellEditingStyleDelete;
        case 2:
            return UITableViewCellEditingStyleInsert;
        default:
            return UITableViewCellEditingStyleNone;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    return [bundle localizedStringForKey:@"CUSTOMIZE_TOGGLES_REMOVE" value:@"Remove" table:@"SortOrder"];
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    if (proposedDestinationIndexPath.section != 2) {
        // Inserting into enabled, no need to alphabetize
        return proposedDestinationIndexPath;
    }

    // Get index of proper alphabetical order
    NSString *identifier = self.enabledIdentifiers[sourceIndexPath.row];
    NSUInteger insertIndex = [self _indexForInsertingItemWithIdentifier:identifier intoArray:self.disabledIdentifiers];

    return [NSIndexPath indexPathForRow:insertIndex inSection:2];
}

#pragma mark - Preferences

- (void)_updateEnabledToggles {
    // Update HBPreferences
    HBPreferences *preferences = [HBPreferences preferencesForIdentifier:@"com.shade.nougat"];
    preferences[NUAPreferencesTogglesListKey] = [self.enabledIdentifiers copy];

    // Post notification
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.shade.nougat/ReloadPrefs"), NULL, NULL, YES);
}

@end
