#import "NUAToggleTableCell.h"

@implementation NUAToggleTableCell

- (void)setToggleInfo:(NUAToggleInfo *)toggleInfo {
    _toggleInfo = toggleInfo;

    // Set label and imate
    self.textLabel.text = toggleInfo.displayName;
    self.imageView.image = toggleInfo.settingsIcon;
}

@end