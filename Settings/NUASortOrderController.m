#import "NUASortOrderController.h"
#import "NUAToggleTableCell.h"
#import <Cephei/HBPreferences.h>
#import <HBLog.h>

@implementation NUASortOrderController

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        // Refresh Installed
        _preferences = [NUAPreferenceManager sharedSettings];
        [self.preferences refreshToggleInfo];

        // Load arrays
        _enabledToggles = [self.preferences.enabledToggles mutableCopy];

        NSArray<NSString *> *currentDisabledToggles = self.preferences.disabledToggles;
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

        _disabledToggles = sortedDisabledToggles;
    }

    return self;
}

#pragma mark - PSListController

- (NSMutableArray<PSSpecifier *> *)specifiers {
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Set Editing
    [self table].editing = YES;

    // Register custom cell class
    [[self table] registerClass:[NUAToggleTableCell class] forCellReuseIdentifier:@"NougatCell"];

    // Add eventual header view
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // Save settings
    [self _updateEnabledToggles];
}

- (UIView *)_tableView:(UITableView *)tableView viewForCustomInSection:(NSInteger)section isHeader:(BOOL)isHeader {
	return nil;
}

- (CGFloat)_tableView:(UITableView *)tableView heightForCustomInSection:(CGFloat)section isHeader:(BOOL)isHeader {
    return 0.0;
}

#pragma mark - Helper methods

- (NSArray<NSString *> *)arrayForSection:(NSInteger)section {
    return (section == 0) ? self.enabledToggles : self.disabledToggles;
}

- (NSString *)_displayNameForIdentifier:(NSString *)identifier {
    return [self.preferences toggleInfoForIdentifier:identifier].displayName;
}

- (NSUInteger)_indexForInsertingItemWithIdentifier:(NSString *)identifier intoArray:(NSArray<NSString *> *)array {
    return [array indexOfObject:identifier inSortedRange:NSMakeRange(0, array.count) options:NSBinarySearchingInsertionIndex usingComparator:^(NSString *id1, NSString *id2) {
        NSString *displayName1 = [self _displayNameForIdentifier:id1];
        NSString *displayName2 = [self _displayNameForIdentifier:id2];

        return [displayName1 compare:displayName2];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self arrayForSection:section].count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"NougatCell";
    NUAToggleTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (!cell) {
        cell = [[NUAToggleTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    NSString *identifier = [self arrayForSection:indexPath.section][indexPath.row];
    NUAToggleInfo *info = [self.preferences toggleInfoForIdentifier:identifier];

    // Customize cell
    cell.toggleInfo = info;

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"INCLUDE";
        case 1:
            return @"MORE TOGGLES";
        default:
            return @"";
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return @"";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        if (self.enabledToggles.count >= 9) {
            // Dont add more than 9 toggles
            return;
        }

        // Move from disabled to enabled
        NSString *identifier = self.disabledToggles[indexPath.row];
        NSUInteger insertIndex = self.enabledToggles.count;
        [self.disabledToggles removeObject:identifier];
        [self.enabledToggles addObject:identifier];

        // Update table
        [tableView beginUpdates];

        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:100];
        [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:insertIndex inSection:0]] withRowAnimation:100];

        [tableView endUpdates];
    } else if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Move from enabled to disabled
        NSString *identifier = self.enabledToggles[indexPath.row];
        NSUInteger insertIndex = [self _indexForInsertingItemWithIdentifier:identifier intoArray:self.disabledToggles];

        [self.enabledToggles removeObject:identifier];
        [self.disabledToggles insertObject:identifier atIndex:insertIndex];

        // Update table
        [tableView beginUpdates];

        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:100];
        [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:insertIndex inSection:1]] withRowAnimation:100];

        [tableView endUpdates];
    }

    [self _updateEnabledToggles];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == 0);
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSMutableArray<NSString *> *sourceArray = (sourceIndexPath.section == 0) ? self.enabledToggles : self.disabledToggles;
    NSMutableArray<NSString *> *destinationArray = (destinationIndexPath.section == 0) ? self.enabledToggles : self.disabledToggles;
    NSString *identifier = sourceArray[sourceIndexPath.row];

    [sourceArray removeObjectAtIndex:sourceIndexPath.row];
    [destinationArray insertObject:identifier atIndex:destinationIndexPath.row];

    [[self table] reloadData];
    [self _updateEnabledToggles];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 28;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return UITableViewCellEditingStyleDelete;
        case 1:
            return UITableViewCellEditingStyleInsert;
        default:
            return UITableViewCellEditingStyleNone;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Remove";
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    if (proposedDestinationIndexPath.section != 1) {
        // Inserting into enabled, no need to alphabetize
        return proposedDestinationIndexPath;
    }

    // Get index of proper alphabetical order
    NSString *identifier = self.enabledToggles[sourceIndexPath.row];
    NSUInteger insertIndex = [self _indexForInsertingItemWithIdentifier:identifier intoArray:self.disabledToggles];

    return [NSIndexPath indexPathForRow:insertIndex inSection:1];
}

- (NSTextAlignment)tableView:(UITableView *)tableView titleAlignmentForHeaderInSection:(NSInteger)section {
    return NSTextAlignmentLeft;
}

- (NSTextAlignment)tableView:(UITableView *)tableView titleAlignmentForFooterInSection:(NSInteger)section {
	return NSTextAlignmentLeft;
}

#pragma mark - Preferences

- (void)_updateEnabledToggles {
    // Update HBPreferences
    HBPreferences *preferences = [HBPreferences preferencesForIdentifier:@"com.shade.nougat"];
    [preferences setObject:[self.enabledToggles copy] forKey:NUAPreferencesTogglesListKey];

    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.shade.nougat/ReloadPrefs"), NULL, NULL, YES);
}

@end
