@protocol SBDashBoardParticipating <NSObject>
@property (readonly, nonatomic) NSInteger participantState;
@property (readonly, copy, nonatomic) NSString *dashBoardIdentifier;

@required

- (NSInteger)participantState;
- (NSString *)dashBoardIdentifier;

@end