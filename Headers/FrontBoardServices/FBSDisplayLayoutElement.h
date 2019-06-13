@protocol FBSDisplayLayoutElement
@property (copy, readonly, nonatomic) NSString *identifier;
@property (readonly, nonatomic) CGRect frame; 
@property (readonly, nonatomic) CGRect referenceFrame; 
@property (readonly, nonatomic) UIWindowLevel level; 

@required
- (CGRect)referenceFrame;
- (NSString *)identifier;
- (CGRect)frame;
- (UIWindowLevel)level;

@end

@protocol SBSDisplayLayoutElement <NSObject>
@property (getter=isSpringBoardElement, readonly, nonatomic) BOOL springBoardElement; 
@property (readonly, nonatomic) NSInteger layoutRole; 
@required

- (BOOL)isSpringBoardElement;
- (NSInteger)layoutRole;

@end

@interface FBSDisplayLayoutElement : NSObject <SBSDisplayLayoutElement, FBSDisplayLayoutElement>
@property (getter=isSpringBoardElement, readonly, nonatomic) BOOL springBoardElement; 
@property (readonly, nonatomic) NSInteger layoutRole; 
@property (copy, nonatomic) NSString *identifier;
@property (assign, nonatomic) CGRect frame; 
@property (assign, nonatomic) CGRect referenceFrame; 
@property (assign, nonatomic) UIWindowLevel level; 
@property (assign, nonatomic) BOOL fillsDisplayBounds;
@property (getter=isUIApplicationElement, nonatomic) BOOL UIApplicationElement;
@property (copy, nonatomic) NSString *bundleIdentifier;
@property (assign, nonatomic) BOOL hasKeyboardFocus;

@end