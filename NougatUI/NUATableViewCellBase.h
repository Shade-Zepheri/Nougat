#import <UIKit/UIKit.h>
#import <NougatServices/NougatServices.h>

@class NUATableViewCellBase;

@protocol NUATableViewCellDelegate <NSObject>
@required

- (void)tableViewCell:(NUATableViewCellBase *)tableViewCell wantsExpansion:(BOOL)expand;

@end

@interface NUATableViewCellBase : UITableViewCell
@property (weak, nonatomic) id<NUATableViewCellDelegate> delegate;
@property (getter=isExpandable, nonatomic) BOOL expandable;
@property (getter=isExpanded, nonatomic) BOOL expanded;

@property (strong, readonly, nonatomic) UIStackView *headerStackView;
@property (copy, nonatomic) NSString *headerText;
@property (strong, nonatomic) UIImage *headerGlyph;
@property (strong, nonatomic) UIColor *headerTint;

@end