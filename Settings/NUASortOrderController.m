#import "NUASortOrderController.h"
#import <NougatServices/NougatServices.h>
#import <Cephei/HBPreferences.h>

@implementation NUASortOrderController

#pragma mark - PSListController

- (NSMutableArray <PSSpecifier *> *)specifiers {
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _togglesList = [NUAPreferenceManager sharedSettings].togglesList;
    [self table].editing = YES;
}

#pragma mark - TableView

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return @"";
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.togglesList count];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"NougatCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    cell.textLabel.text = self.togglesList[indexPath.row];
    cell.backgroundColor = [UIColor colorWithRed:0.74 green:0.89 blue:1.00 alpha:1.0];

    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (NSInteger)tableView:(UITableView *)tableView titleAlignmentForFooterInSection:(NSInteger)section {
	return 1;
}

- (UIView *)_tableView:(UITableView *)tableView viewForCustomInSection:(NSInteger)section isHeader:(BOOL)isHeader {
	return nil;
}

- (CGFloat)_tableView:(UITableView *)tableView heightForCustomInSection:(CGFloat)section isHeader:(BOOL)isHeader {
    return 0.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSMutableArray *array = [self.togglesList mutableCopy];
    NSString *string = array[sourceIndexPath.row];

    [array removeObjectAtIndex:sourceIndexPath.row];
    [array insertObject:string atIndex:destinationIndexPath.row];
    [self _updateTogglesArray:[array copy]];
}


- (void)_updateTogglesArray:(NSArray *)array {
    // Update ivar
    _togglesList = array;

    // Update HBPreferences
    HBPreferences *preferences = [HBPreferences preferencesForIdentifier:@"com.shade.nougat"];
    [preferences setObject:array forKey:NUAPreferencesTogglesListKey];

    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.shade.nougat/ReloadPrefs"), NULL, NULL, YES);
}

@end
