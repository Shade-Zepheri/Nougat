@protocol CSCoverSheetParticipating <NSObject>
@property (readonly, nonatomic) NSInteger participantState;
@property (readonly, copy, nonatomic) NSString *coverSheetIdentifier;

@required

- (NSInteger)participantState;
- (NSString *)coverSheetIdentifier;

@end