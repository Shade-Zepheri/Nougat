#import "NUAStatusBar.h"

@implementation NUAStatusBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blueColor];

        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.dateFormat = @"h:mm a - EEE, MMM d";

        self.dateString = [self.dateFormatter stringFromDate:[NSDate date]];

        [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
    }

    return self;
}

- (void)updateTime:(NSTimer*)timer {
    self.dateString = [self.dateFormatter stringFromDate:[NSDate date]];
    //update label
}

@end
