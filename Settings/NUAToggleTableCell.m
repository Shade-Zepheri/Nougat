#import "NUAToggleTableCell.h"

@implementation NUAToggleTableCell

- (void)setToggleDescription:(NUAToggleDescription *)toggleDescription {
    _toggleDescription = toggleDescription;

    // Set label and imate
    self.textLabel.text = toggleDescription.displayName;
    self.imageView.image = toggleDescription.iconImage;
}

@end