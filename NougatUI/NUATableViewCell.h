#import <UIKit/UIKit.h>
#import <NougatServices/NougatServices.h>

@class NUATableViewCell;

@protocol NUATableViewCellDelegate <NSObject>
@required

- (void)tableViewCell:(NUATableViewCell *)cell wantsExpansion:(BOOL)expand;

@end

@interface NUATableViewCell : UITableViewCell
@property (weak, nonatomic) id<NUATableViewCellDelegate> delegate;
@property (getter=isExpanded, nonatomic) BOOL expanded;

@property (strong, nonatomic) NUAPreferenceManager *notificationShadePreferences;

@property (strong, readonly, nonatomic) UIStackView *headerStackView;
@property (copy, nonatomic) NSString *headerText;
@property (strong, nonatomic) UIImage *headerGlyph;
@property (strong, nonatomic) UIColor *headerTint;

@end