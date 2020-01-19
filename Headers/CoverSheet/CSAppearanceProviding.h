@class _UILegibilitySettings;

@protocol CSAppearanceProviding <NSObject>
@property (copy, readonly, nonatomic) NSString *appearanceIdentifier; 
@property (readonly, nonatomic) NSInteger backgroundStyle; 
@property (copy, readonly, nonatomic) NSSet *components; 
@property (readonly, nonatomic) _UILegibilitySettings *legibilitySettings;
@property (readonly, nonatomic) UIColor *backgroundColor;

@required

- (NSSet *)components;
- (UIColor *)backgroundColor;
- (_UILegibilitySettings *)legibilitySettings;
- (NSInteger)backgroundStyle;
- (NSString *)appearanceIdentifier;

@end