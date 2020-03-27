#import <UIKit/UIKit.h>

@class NUARelativeDateLabel;

@protocol NUADateLabelDelegate <NSObject>
@required

- (void)dateLabelDidChange:(NUARelativeDateLabel *)dateLabel;

@end

@interface NUARelativeDateLabel : UILabel
@property (strong, readonly, nonatomic) NSDate *timeZoneRelativeStartDate;
@property (weak, nonatomic) id<NUADateLabelDelegate> delegate;

- (void)startCollectingUpdates;
- (void)endCollectingUpdates;

- (void)setStartDate:(NSDate *)startDate withTimeZone:(NSTimeZone *)timeZone;

- (void)prepareForReuse;

@end