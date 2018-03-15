#import <Preferences/PSSpecifier.h>
#import <Preferences/PSViewController.h>
#import <UIKit/UIKit.h>

static NSString *const NUAPreferencesPath = @"/var/mobile/Library/Preferences/com.shade.nougat.plist";

@interface NUASortOrderController : PSViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *quickToggleArray;
@property (strong, nonatomic) NSMutableArray *mainToggleArray;

@end
