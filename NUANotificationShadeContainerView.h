#import "NUAModulesContainerViewController.h"
#import "NUANotificationShadePanelView.h"
#import <UIKit/UIView+Internal.h>
#import <UIKit/_UIBackdropView.h>

@class NUANotificationShadeContainerView;

@protocol NUANotificationShadeContainerViewDelegate <NSObject>
@required

- (NUANotificationShadePanelView *)notificationPanelForContainerView:(NUANotificationShadeContainerView *)containerView;

@end

@interface NUANotificationShadeContainerView : UIView {
    _UIBackdropView *_backdropView;
}

@property (weak, nonatomic) id<NUANotificationShadeContainerViewDelegate> delegate;
@property (nonatomic) CGFloat presentedHeight;
@property (getter=isChangingBrightness, nonatomic) BOOL changingBrightness;

- (instancetype)initWithFrame:(CGRect)frame andDelegate:(id<NUANotificationShadeContainerViewDelegate>)delegate;

@end
