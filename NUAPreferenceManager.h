@interface NUAPreferenceManager : NSObject {
    NSDictionary *_settings;
}
@property (assign, readonly, nonatomic) BOOL enabled;
@property (strong, readonly, nonatomic) UIColor *backgroundColor;
@property (strong, readonly, nonatomic) UIColor *highlightColor;
@property (strong, nonatomic) NSMutableArray *quickToggleOrder;
@property (strong, nonatomic) NSMutableArray *mainPanelOrder;
+ (instancetype)sharedSettings;
- (void)reloadSettings;
+ (NSString*)currentWifiSSID;
@end
