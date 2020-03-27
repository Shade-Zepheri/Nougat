#import <UIKit/UIKit.h>
#import "NUARelativeDateLabel.h"

@interface NUADateLabelRepository : NSObject
@property (class, strong, readonly) NUADateLabelRepository *sharedRepository;

- (NUARelativeDateLabel *)startLabelWithStartDate:(NSDate *)startDate timeZone:(NSTimeZone *)timeZone;

- (void)recycleLabel:(NUARelativeDateLabel *)label;

@end