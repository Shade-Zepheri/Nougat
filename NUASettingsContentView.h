#import <UIKit/UIKit.h>

@interface NUASettingsContentView : UIView {
    NSDateFormatter *_dateFormatter;
    UIView *_dividerView;
    NSLayoutConstraint *_accountConstraint;
    NSLayoutConstraint *_preferencesConstraint;
}

@property (strong, nonatomic) NSDate *date;
@property (assign, nonatomic) CGFloat expandedPercent;

@property (strong, readonly, nonatomic) UILabel *dateLabel;

@property (strong, readonly, nonatomic) UIImageView *arrowView;
@property (strong, readonly, nonatomic) UIImageView *settingsView;
@property (strong, readonly, nonatomic) UIImageView *nougatView;
@property (strong, readonly, nonatomic) UIImageView *accountView;

@end