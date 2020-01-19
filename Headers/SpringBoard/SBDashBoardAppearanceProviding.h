@class SBDashBoardLayoutStrategy, _UILegibilitySettings;

@protocol SBDashBoardAppearanceProviding <NSObject>
@property (copy, readonly, nonatomic) NSString *appearanceIdentifier; 
@property (readonly, nonatomic) NSInteger backgroundStyle; 
@property (copy, readonly, nonatomic) NSSet *components; 
@property (readonly, nonatomic) _UILegibilitySettings *legibilitySettings;
@property (readonly, nonatomic) UIColor *backgroundColor;
@property (strong, nonatomic) SBDashBoardLayoutStrategy *layoutStrategy;

@required

- (NSSet *)components;
- (UIColor *)backgroundColor;
- (_UILegibilitySettings *)legibilitySettings;
- (NSInteger)backgroundStyle;
- (NSString *)appearanceIdentifier;
- (SBDashBoardLayoutStrategy *)layoutStrategy;

@end