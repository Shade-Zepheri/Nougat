typedef NS_ENUM(NSUInteger, NUADrawerTheme) {
		NUADrawerThemeNexus,
		NUADrawerThemePixel,
		NUADrawerThemeOreo
};

@interface NUAPreferenceManager : NSObject

@property (assign, readonly, nonatomic) BOOL enabled;
@property (strong, readonly, nonatomic) UIColor *backgroundColor;
@property (strong, readonly, nonatomic) UIColor *highlightColor;
@property (copy, readonly, nonatomic) NSArray <NSString *> *quickToggleOrder;
@property (copy, readonly, nonatomic) NSArray <NSString *> *mainPanelOrder;

+ (instancetype)sharedSettings;

+ (NSString *)currentWifiSSID;
+ (NSString *)carrierName;

@end
