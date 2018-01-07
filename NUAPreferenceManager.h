typedef NS_ENUM(NSUInteger, NUADrawerTheme) {
		NUADrawerThemeNexus,
		NUADrawerThemePixel,
		NUADrawerThemeOreo
};

@interface NUAPreferenceManager : NSObject {
    NSDictionary *_settings;
}

@property (assign, readonly, nonatomic) BOOL enabled;
@property (strong, readonly, nonatomic) UIColor *backgroundColor;
@property (strong, readonly, nonatomic) UIColor *highlightColor;
@property (copy, readonly, nonatomic) NSArray *quickToggleOrder;
@property (copy, readonly, nonatomic) NSArray *mainPanelOrder;

+ (instancetype)sharedSettings;
- (void)reloadSettings;

+ (NSString *)currentWifiSSID;
+ (NSString *)carrierName;

@end
