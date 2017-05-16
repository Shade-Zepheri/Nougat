#import <UIKit/UIKit.h>
#import <Preferences/PSViewController.h>

static NSString * const NUAPreferencePath = @"/var/mobile/Library/Preferences/com.shade.nougat.plist";

@interface NUASortOrderController : PSViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *quickToggleArray;
@property (strong, nonatomic) NSMutableArray *mainToggleArray;
@end
