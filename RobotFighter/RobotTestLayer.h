//
//  RobotTestLayer.h
//  BasicCocos2D
//
//  Created by Ian Fan on 22/10/12.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ObjectiveChipmunk.h"
#import "CPDebugLayer.h"
#import "RobotTestC.h"
#import "RobotTestSingleton.h"

@interface RobotTestLayer : CCLayer
{
  ChipmunkSpace *_space;
  ChipmunkMultiGrab *_multiGrab;
  CPDebugLayer *_debugLayer;
  
  int group1Count;
  int group2Count;
}

+(CCScene *) scene;

@end
