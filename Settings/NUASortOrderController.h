#import <UIKit/UIKit.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSViewController.h>

@interface NUASortOrderController : PSViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (copy, readonly, nonatomic) NSArray <NSString *> *togglesList;

@end
