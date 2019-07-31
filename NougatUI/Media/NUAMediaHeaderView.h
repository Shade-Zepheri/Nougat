#import <UIKit/UIKit.h>

@interface NUAMediaHeaderView : UIView
@property (getter=isExpanded, nonatomic) BOOL expanded;

@property (copy, nonatomic) NSString *nowPlayingApp;
@property (copy, nonatomic) NSString *album;
@property (copy, nonatomic) NSString *song;
@property (copy, nonatomic) NSString *artist;
@property (strong, nonatomic) UIColor *tintColor;

@end