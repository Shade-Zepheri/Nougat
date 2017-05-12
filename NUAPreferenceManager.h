@interface NUAPreferenceManager : NSObject {
    NSDictionary *_settings;
}
@property (assign, readonly, nonatomic) BOOL enabled;
@property (strong, readonly, nonatomic) UIColor *backgroundColor;
+ (instancetype)sharedSettings;
- (void)reloadSettings;
+ (NSString*)currentWifiSSID;
@end
