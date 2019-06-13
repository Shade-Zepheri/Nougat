#import <FrontBoardServices/FBSDisplayLayoutElement.h>

typedef NS_ENUM(NSInteger, SBSDisplayLayoutRole) {
    SBSDisplayLayoutRoleUndefined,
    SBSDisplayLayoutRolePrimary,
    SBSDisplayLayoutRoleSecondary,
    SBSDisplayLayoutRoleFullScreenModal,
    SBSDisplayLayoutRoleOverlay,
    SBSDisplayLayoutRolePiP,
    SBSDisplayLayoutRoleEmbedded,
    SBSDisplayLayoutRoleFloating
};

@interface SBSDisplayLayoutElement : FBSDisplayLayoutElement <SBSDisplayLayoutElement>
@property (getter=isSpringBoardElement, readonly, nonatomic) BOOL springBoardElement;
@property (assign, nonatomic) SBSDisplayLayoutRole layoutRole;

- (instancetype)initWithIdentifier:(NSString *)identifier layoutRole:(SBSDisplayLayoutRole)layoutRole;

@end