#import "NSDate+Elapsed.h"
#import <HBLog.h>

@implementation NSDate (Elapsed)

- (NSString *)getElapsedTime {
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:self toDate:[NSDate date] options:0];

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSInteger days = dateComponents.day;
    if (days > 0) {
        NSString *baseFormat = [bundle localizedStringForKey:@"RELATIVE_DATE_PAST_DAYS" value:@"%zdd" table:@"Localizable"];
        return [NSString stringWithFormat:baseFormat, days];
    }

    NSInteger hours = dateComponents.hour;
    if (hours > 0) {
        NSString *baseFormat = [bundle localizedStringForKey:@"RELATIVE_DATE_PAST_HOURS" value:@"%zdh" table:@"Localizable"];
        return [NSString stringWithFormat:baseFormat, hours];
    }

    NSInteger minutes = dateComponents.minute;
    if (minutes > 0) {
        NSString *baseFormat = [bundle localizedStringForKey:@"RELATIVE_DATE_PAST_MINUTES" value:@"%zdm" table:@"Localizable"];
        return [NSString stringWithFormat:baseFormat, minutes];
    } 

    return [bundle localizedStringForKey:@"RELATIVE_DATE_PAST_SECONDS" value:@"now" table:@"Localizable"];
}

@end