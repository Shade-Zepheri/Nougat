#import "NUASortOrderController.h"
#import "NUARootListController.h"
#import "NUAPreferenceManager.h"

@implementation NUASortOrderController

- (NSArray *)specifiers {
    return nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.editing = YES;
        self.tableView.allowsSelection = YES;
        self.tableView.allowsSelectionDuringEditing = YES;

        _quickToggleArray = [[NUAPreferenceManager sharedSettings].quickToggleOrder mutableCopy];
        _mainToggleArray = [[NUAPreferenceManager sharedSettings].mainPanelOrder mutableCopy];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = nil;
    switch (section) {
      case 0:
          sectionTitle = @"Quick Toggle Order";
          break;
      case 1:
          sectionTitle = @"Main Panel Order";
          break;
    }

    return sectionTitle;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows;
    switch (section) {
      case 0:
          rows = [self.quickToggleArray count];
          break;
      case 1:
          rows = [self.mainToggleArray count];
          break;
    }

    return rows;
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

    NSMutableArray *titleArray = nil;
    if (indexPath.section == 0) {
        titleArray = self.quickToggleArray;
    } else {
        titleArray = self.mainToggleArray;
    }

    cell.textLabel.text = titleArray[indexPath.row];

    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSMutableArray *array = sourceIndexPath.section == 0 ? self.quickToggleArray : self.mainToggleArray;
    NSString *string = [array objectAtIndex:sourceIndexPath.row];

    [array removeObjectAtIndex:sourceIndexPath.row];
    [array insertObject:string atIndex:destinationIndexPath.row];
    [self setPreferenceValue:[array copy] forKey:sourceIndexPath.section == 0 ? @"quickToggleOrder" : @"mainPanelOrder"];
}


- (void)setPreferenceValue:(id)value forKey:(NSString *)key {
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:NUAPreferencePath]];
    [defaults setObject:value forKey:key];
    [defaults writeToFile:NUAPreferencePath atomically:YES];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.shade.nougat/ReloadPrefs"), NULL, NULL, YES);
}

@end
