@interface BSDateFormatterCache : NSObject

+ (BSDateFormatterCache *)sharedInstance;

- (void)resetFormattersIfNecessary;

- (NSString *)formatDateAsTimeNoAMPM:(NSDate *)date;

@end