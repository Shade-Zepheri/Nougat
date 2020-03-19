#import "PSSegmentTableCell+Enable.h"

@implementation PSSegmentTableCell (Enable)

- (void)setCellEnabled:(BOOL)enabled {
    [super setCellEnabled:enabled];

    // Disable and grey out control
    UISegmentedControl *segmentedControl = (UISegmentedControl *)self.control;
    for (int i = 0; i < segmentedControl.numberOfSegments; i++) {
        [segmentedControl setEnabled:enabled forSegmentAtIndex:i];
    }
}

@end