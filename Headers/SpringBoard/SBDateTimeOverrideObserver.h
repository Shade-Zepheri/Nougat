@class SBDateTimeController;

@protocol SBDateTimeOverrideObserver <NSObject>
@required

- (void)controller:(SBDateTimeController *)controller didChangeOverrideDateFromDate:(NSDate *)date;

@end
