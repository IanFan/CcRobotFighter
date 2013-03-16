//
//  RobotTestSingleton.h
//  BasicCocos2D
//
//  Created by Ian Fan on 22/10/12.
//
//

#import <Foundation/Foundation.h>
#import "RobotTestC.h"

@interface RobotTestSingleton : NSObject

//@property (nonatomic,retain) NSMutableArray *robotArray;
@property (nonatomic,retain) NSMutableArray *robot1Array;
@property (nonatomic,retain) NSMutableArray *robot2Array;
@property (nonatomic,retain) NSMutableArray *obstacleArray;

+(id)sharedInstance;

@end
