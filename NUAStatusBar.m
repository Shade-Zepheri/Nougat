#import "NUAStatusBar.h"

@implementation NUAStatusBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, frame.size.width / 2, frame.size.height)];
        self.dateLabel.font = [UIFont systemFontOfSize:14];
        self.dateLabel.textColor = [UIColor whiteColor];
        self.dateLabel.backgroundColor = [UIColor clearColor];
        self.dateLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.dateLabel];

        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.dateFormat = @"h:mm a - EEE, MMM d";

        NSString *dateString = [self.dateFormatter stringFromDate:[NSDate date]];
        self.dateLabel.text = dateString;

        [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
    }

    return self;
}

- (void)updateTime:(NSTimer*)timer {
    NSString *dateString = [self.dateFormatter stringFromDate:[NSDate date]];
    self.dateLabel.text = dateString;
}

@end
