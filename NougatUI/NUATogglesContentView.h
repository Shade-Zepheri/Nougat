#import "NUANotificationShadeModuleView.h"
#import "NUAToggleInstancesProvider.h"

@class NUATogglesContentView;

@protocol NUATogglesContentViewDelegate <NSObject>

- (void)contentViewWantsNotificationShadeDismissal:(NUATogglesContentView *)contentView;

@end

@interface NUATogglesContentView : NUANotificationShadeModuleView <NUAToggleButtonDelegate> {
    CGFloat _targetWidthConstant;

    NSArray<NUAToggleButton *> *_topRow;
    NSArray<NUAToggleButton *> *_middleRow;
    NSArray<NUAToggleButton *> *_bottomRow;
}

@property (weak, nonatomic) id<NUATogglesContentViewDelegate> delegate;
@property (assign, nonatomic) CGFloat expandedPercent;
@property (getter=isArranged, readonly, nonatomic) BOOL arranged;

@property (strong, readonly, nonatomic) NUAToggleInstancesProvider *togglesProvider;
@property (copy, nonatomic) NSArray<NUAToggleButton *> *togglesArray;

- (void)_layoutToggles;
- (void)refreshToggleLayout;

@end