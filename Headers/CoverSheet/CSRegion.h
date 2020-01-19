typedef NS_ENUM(NSInteger, CSRegionRole) {
    CSRegionRoleNone,
    CSRegionRoleAccessory,
    CSRegionRoleContent,
    CSRegionRoleOverlay,
};

@interface CSRegion : NSObject <NSCopying, UICoordinateSpace>
@property (assign, nonatomic) CSRegionRole role;

+ (instancetype)regionForCoordinateSpace:(id<UICoordinateSpace>)coordinateSpace;

- (instancetype)role:(CSRegionRole)role;

@end