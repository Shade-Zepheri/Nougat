typedef struct AnalyzedInfo {
    int bg;
    int primary;
    int secondary;
    BOOL darkBG;
} AnalyzedInfo;

@interface CFWColorInfo : NSObject
@property(nonatomic, retain) UIColor *backgroundColor;
@property(nonatomic, retain) UIColor *primaryColor;
@property(nonatomic, retain) UIColor *secondaryColor;
@property(nonatomic, assign, getter=isBackgroundDark) BOOL backgroundDark;

+ (instancetype)colorInfoWithAnalyzedInfo:(struct AnalyzedInfo)info;

- (instancetype)initWithAnalyzedInfo:(struct AnalyzedInfo)info;

@end

@interface CFWBucket : NSObject

+ (struct AnalyzedInfo)analyzeImage:(UIImage *)image resize:(BOOL)resize;

@end