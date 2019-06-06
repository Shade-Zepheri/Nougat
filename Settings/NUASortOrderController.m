#import "NUASortOrderController.h"
#import "NUAToggleTableCell.h"
#import <Cephei/HBPreferences.h>
#import <HBLog.h>

@implementation NUASortOrderController

#pragma mark - PSListController

- (NSMutableArray<PSSpecifier *> *)specifiers {
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Refresh Installed
    _preferences = [NUAPreferenceManager sharedSettings];
    [self.preferences refreshToggleInfo];

    // Register custom cell class
    [[self table] registerClass:[NUAToggleTableCell class] forCellReuseIdentifier:@"NougatCell"];

    // Load arrays
    _enabledToggles = [self.preferences.enabledToggles mutableCopy];
    _disabledToggles = [self.preferences.disabledToggles mutableCopy];

    // Set Editing
    [self table].editing = YES;
}

- (UIView *)_tableView:(UITableView *)tableView viewForCustomInSection:(NSInteger)section isHeader:(BOOL)isHeader {
	return nil;
}

- (CGFloat)_tableView:(UITableView *)tableView heightForCustomInSection:(CGFloat)section isHeader:(BOOL)isHeader {
    return 0.0;
}

- (NSArray<NSString *> *)arrayForSection:(NSInteger)section {
    return (section == 0) ? self.enabledToggles : self.disabledToggles;
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
            return @"Enabled Toggles";
        case 1:
            return @"Disabled Toggles";
        default:
            return @"";
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return @"";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Add toggles
        [tableView beginUpdates];

        // Add to enabled list
        NSString *identifier = self.disabledToggles[indexPath.row];
        [self.enabledToggles addObject:identifier];

        [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.enabledToggles indexOfObject:identifier] inSection:0]] withRowAnimation:UITableViewRowAnimationFade];

        // Remove from disabled
        [self.disabledToggles removeObject:identifier];

        [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:1]] withRowAnimation:YES];

        [tableView endUpdates];
    } else if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Remove toggles
        [tableView beginUpdates];

        NSString *identifier = self.enabledToggles[indexPath.row];
        [self.disabledToggles addObject:identifier];

        [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.disabledToggles indexOfObject:identifier] inSection:1]] withRowAnimation:UITableViewRowAnimationFade];

        // Remove from enabled
        [self.enabledToggles removeObject:identifier];

        [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:0]] withRowAnimation:YES];

        [tableView endUpdates];
    }

    [self _updateEnabledToggles];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
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

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (NSInteger)tableView:(UITableView *)tableView titleAlignmentForHeaderInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView titleAlignmentForFooterInSection:(NSInteger)section {
	return 1;
}

#pragma mark - Preferences

- (void)_updateEnabledToggles {
    // Update HBPreferences
    HBPreferences *preferences = [HBPreferences preferencesForIdentifier:@"com.shade.nougat"];
    [preferences setObject:[self.enabledToggles copy] forKey:NUAPreferencesTogglesListKey];

    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.shade.nougat/ReloadPrefs"), NULL, NULL, YES);
}

@end
