//
//  RobotFighterLayer.h
//  RobotFighter
//
//  Created by Ian Fan on 14/03/13.
//
//

#import "cocos2d.h"
#import "ObjectiveChipmunk.h"
#import "CPDebugLayer.h"
#import "RobotFighter.h"

@interface RobotFighterLayer : CCLayer
{
  ChipmunkSpace *_space;
  ChipmunkMultiGrab *_multiGrab;
  
  RobotFighter *_robotFighter;
  
  CGPoint _touchingPoint;
}
+(CCScene *) scene;

@end
