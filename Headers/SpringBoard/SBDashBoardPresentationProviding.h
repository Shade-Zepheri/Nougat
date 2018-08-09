@protocol SBDashBoardPresentationProviding <NSObject>
@property (weak, readonly, nonatomic) id<UICoordinateSpace> presentationCoordinateSpace; 
@property (copy, readonly, nonatomic) NSArray *presentationRegions; 

@required

- (id<UICoordinateSpace>)presentationCoordinateSpace;
- (NSArray *)presentationRegions;

@end