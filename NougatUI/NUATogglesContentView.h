#import "NUANotificationShadeModuleView.h"
#import "NUAToggleInstancesProvider.h"

@class NUATogglesContentView;

@protocol NUATogglesContentViewDelegate <NSObject>

- (void)contentViewWantsNotificationShadeDismissal:(NUATogglesContentView *)contentView;

@end

@interface NUATogglesContentView : NUANotificationShadeModuleView <NUAToggleButtonDelegate>
@property (weak, nonatomic) id<NUATogglesContentViewDelegate> delegate;
@property (assign, nonatomic) CGFloat expandedPercent;
@property (getter=isArranged, readonly, nonatomic) BOOL arranged;

@property (copy, readonly, nonatomic) NSArray<NUAToggleButton *> *toggleButtons;

- (void)populateWithToggles:(NSArray<NUAToggleButton *> *)toggleButtons;
- (void)tearDownCurrentToggles;

@end