#import "NUADetailedTextCell.h"

@implementation NUADetailedTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];
    if (self) {
        // Update label properties
        self.textLabel.numberOfLines = 0;
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }

    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width {
    return 200.0;
}

@end
