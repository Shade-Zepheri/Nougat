#import <UIKit/UIKit.h>
#import "NUAFlipswitchToggle.h"

@class NUATogglesContentView;

@protocol NUATogglesContentViewDelegate <NSObject>

- (void)contentViewWantsNotificationShadeDismissal:(NUATogglesContentView *)contentView;

@end

@interface NUATogglesContentView : UIView <NUAFlipswitchToggleDelegate> {
    CGFloat _startingWidth;
    CGFloat _widthDifference;

    NSArray<NUAFlipswitchToggle *> *_topRow;
    NSArray<NUAFlipswitchToggle *> *_middleRow;
    NSArray<NUAFlipswitchToggle *> *_bottomRow;

    UIView *_topContainerView;
    UIView *_middleContainerView;
    UIView *_bottomContainerView;
}

@property (weak, nonatomic) id<NUATogglesContentViewDelegate> delegate;
@property (assign, nonatomic) CGFloat expandedPercent;
@property (getter=isArranged, readonly, nonatomic) BOOL arranged;

@property (copy, nonatomic) NSArray<NUAFlipswitchToggle *> *togglesArray;

- (void)_layoutToggles;
- (void)refreshToggleLayout;

@end