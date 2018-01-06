#import <UIKit/UIKit.h>
#import <Preferences/PSViewController.h>

@interface NUASortOrderController : PSViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *quickToggleArray;
@property (strong, nonatomic) NSMutableArray *mainToggleArray;

@end
