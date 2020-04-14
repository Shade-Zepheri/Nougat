#import "NUASortOrderHeaderView.h"
#import <HBLog.h>

@implementation NUASortOrderHeaderView

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Configure label
        _label = [[UILabel alloc] init];
        _label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _label.numberOfLines = 0;
        _label.textAlignment = NSTextAlignmentCenter;

        if (@available(iOS 13, *)) {
            _label.textColor = [UIColor labelColor];
        } else {
            _label.textColor = [UIColor blackColor];
        }

        [self addSubview:_label];
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    _label.frame = [self _labelFrameForBoundsWidth:CGRectGetWidth(self.bounds)];
}

#pragma mark - Properties

- (NSString *)text {
    return _label.text;
}

- (void)setText:(NSString *)text {
    _label.text = text;
}

#pragma mark - Sizing

- (CGRect)_labelFrameForBoundsWidth:(CGFloat)width {
    CGSize labelSize = [_label sizeThatFits:CGSizeMake(width - 60, CGFLOAT_MAX)];
    return CGRectMake(30, 0, width - 60, labelSize.height);
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self _labelFrameForBoundsWidth:size.width].size;
}

@end