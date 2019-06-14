#import "NUAModulesContainerViewController.h"
#import "NUANotificationShadePanelView.h"

@class NUANotificationShadeContainerView;

@protocol NUANotificationShadeContainerViewDelegate <NSObject>
@required

- (NUANotificationShadePanelView *)notificationPanelForContainerView:(NUANotificationShadeContainerView *)containerView;

@end

@interface NUANotificationShadeContainerView : UIView
@property (weak, nonatomic) id<NUANotificationShadeContainerViewDelegate> delegate;
@property (strong, readonly, nonatomic) UIVisualEffectView *darkeningView;
@property (assign, nonatomic) CGFloat presentedHeight;
@property (getter=isChangingBrightness, nonatomic) BOOL changingBrightness;

- (instancetype)initWithFrame:(CGRect)frame andDelegate:(id<NUANotificationShadeContainerViewDelegate>)delegate;

@end
