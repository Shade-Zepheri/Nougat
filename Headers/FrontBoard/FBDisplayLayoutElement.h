typedef NS_ENUM(NSInteger, FBSDisplayType) {
    FBSDisplayTypeMain,
    FBSDisplayTypeAirplay,
    FBSDisplayTypeUndefined,
    FBSDisplayTypeCar,
    FBSDisplayTypeiPodOnly,
    FBSDisplayTypeMusicOnly,
    FBSDisplayTypeCarInstruments,
    FBSDisplayTypeUnknown
};

@class FBSDisplayLayoutElement;

@interface FBDisplayLayoutElement : NSObject
@property (readonly, nonatomic) FBSDisplayType displayType;
@property (copy, readonly, nonatomic) NSString *identifier;
@property (readonly, nonatomic) FBSDisplayLayoutElement *element;
@property (readonly, nonatomic) Class elementClass;

- (instancetype)initWithDisplayType:(FBSDisplayType)displayType identifier:(NSString *)identifier elementClass:(Class)class;

- (void)activateWithBuilder:(FBSDisplayLayoutElement *(^)(FBSDisplayLayoutElement *element))builder;
- (void)deactivate;

@end