#import "NUAToggleTableCell.h"

@implementation NUAToggleTableCell

- (void)setToggleInfo:(NUAToggleInfo *)toggleInfo {
    _toggleInfo = toggleInfo;

    self.textLabel.text = toggleInfo.displayName;
}

@end