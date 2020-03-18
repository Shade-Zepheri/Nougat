// Exists as part of springboard in ios 10-12, but in ios 13 its now part of springboard home
// hence why im putting this header here, also to not interfere with the outdated headers built in with theos


@interface SBRootFolderController : UIViewController
@property (getter=isEditing, assign, nonatomic) BOOL editing;

- (void)setEditing:(BOOL)editing animated:(BOOL)animated;

@end