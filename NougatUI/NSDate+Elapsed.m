#import "NSDate+Elapsed.h"

@implementation NSDate (Elapsed)

- (NSString *)getElapsedTime {
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:self toDate:[NSDate date] options:0];

    NSInteger days = dateComponents.day;
    if (days > 0) {
        return [NSString stringWithFormat:@"%zd d", days];
    }

    NSInteger hours = dateComponents.hour;
    if (hours > 0) {
        return [NSString stringWithFormat:@"%zd h", hours];
    }

    NSInteger minutes = dateComponents.minute;
    if (minutes > 0) {
        return [NSString stringWithFormat:@"%zd m", minutes];
    } 

    return @"now";
}

@end