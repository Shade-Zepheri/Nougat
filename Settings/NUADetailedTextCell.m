#import "NUADetailedTextCell.h"

@implementation NUADetailedTextCell

- (void)layoutSubviews {
    [super layoutSubviews];

    self.textLabel.numberOfLines = 0;
    self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width {
    return 200.0;
}

@end
