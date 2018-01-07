#import <Preferences/PSSpecifier.h>
#import <Preferences/PSViewController.h>
#import <UIKit/UIKit.h>

@interface NUASortOrderController : PSViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *quickToggleArray;
@property (strong, nonatomic) NSMutableArray *mainToggleArray;

@end
