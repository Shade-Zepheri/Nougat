#import "NUAUserGuideController.h"
#import "NUAVideoTableCell.h"

@implementation NUAUserGuideController

+ (NSString *)hb_specifierPlist {
    return @"Guide";
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSArray<PSTableCell *> *visibleCells = [self table].visibleCells;
    if (!visibleCells || visibleCells.count < 1) {
        // No cells
        return;
    }

    // Check first cell
    [self checkIfCellIsVisible:visibleCells.firstObject inScrollView:scrollView];

    // Check last cell
    [self checkIfCellIsVisible:visibleCells.lastObject inScrollView:scrollView];

    // Since getting list of visible cells, rest are guaranteed visible
    for (int i = 1; i < visibleCells.count - 1; i++) {
        PSTableCell *cell = visibleCells[i];
        if (![cell isKindOfClass:[NUAVideoTableCell class]]) {
            // Not video cell, do nothing
            continue;
        }

        NUAVideoTableCell *videoCell = (NUAVideoTableCell *)cell;
        videoCell.paused = NO;
    }
}

- (void)checkIfCellIsVisible:(PSTableCell *)cell inScrollView:(UIScrollView *)scrollView {
    if (![cell isKindOfClass:[NUAVideoTableCell class]]) {
        // Not video cell, do nothing
        return;
    }

    NUAVideoTableCell *videoCell = (NUAVideoTableCell *)cell;
    CGRect frame = [scrollView convertRect:videoCell.frame toView:scrollView.superview];
    videoCell.paused = !CGRectContainsRect(scrollView.frame, frame);
}

@end
