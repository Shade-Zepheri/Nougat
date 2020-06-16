#import <Preferences/PSViewController.h>
#import <NougatServices/NougatServices.h>

@interface NUASortOrderController : PSViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, readonly, nonatomic) NUAPreferenceManager *preferences;
@property (strong, readonly, nonatomic) UITableViewController *tableViewController;

@end
