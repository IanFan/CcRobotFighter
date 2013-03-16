//
//  RobotTestSingleton.m
//  BasicCocos2D
//
//  Created by Ian Fan on 22/10/12.
//
//

#import "RobotTestSingleton.h"

@implementation RobotTestSingleton

+(id)sharedInstance {
  static id shared = nil;
  if (shared == nil) shared= [[RobotTestSingleton alloc]init];
  
  return shared;
}

#pragma mark -
#pragma mark Init

-(void)setStandardRobotWithArray:(NSMutableArray*)robotArray_ group:(int)group_ {
  RobotTestC *robotTestC = [[[RobotTestC alloc]init]autorelease];
  
  NSString *collosionType;
  CGPoint vel;
  int grouptag;
  CGPoint point;
  
  if (group_ == 1) {
    grouptag = 1;
    collosionType = @"group1Type";
    vel = ccp(2, 0);
    robotTestC.mainSprite = [CCSprite spriteWithFile:@"circleRed.png"];
    point = ccp(-1000, 0);
  }else if(group_ == 2) {
    grouptag = 2;
    collosionType = @"group2Type";
    vel = ccp(-2, 0);
    robotTestC.mainSprite = [CCSprite spriteWithFile:@"circleBlue.png"];
    point = ccp(2000, 0);
  }
  
  [robotTestC setChipmunkObjectsWithShapeStyle:CpShapeCircle mass:1.0 sizeWidth:40 sizeHeight:40 positionX:point.x positionY:point.y elasticity:0.0 friction:2.0 collisionType:collosionType];
  [robotTestC setChipmunkBodyVel:vel velLimit:2];
  robotTestC.groupTag = grouptag;
  
  [robotArray_ addObject:robotTestC];
}

-(void)setStandardObstacleWithPoint:(CGPoint)point_ {
  RobotTestC *robotTestC = [[[RobotTestC alloc]init]autorelease];
  int scale = 3;
  
  [robotTestC setChipmunkObjectsWithShapeStyle:CpShapeCircle mass:INFINITY sizeWidth:40*scale sizeHeight:40*scale positionX:point_.x positionY:point_.y elasticity:0.0 friction:2.0 collisionType:@"none"];
  
  robotTestC.mainSprite = [CCSprite spriteWithFile:@"circleWhite.png"];
  robotTestC.mainSprite.scale = 1.0*scale;
  robotTestC.mainSprite.position = point_;
  [robotTestC setChipmunkBodyVel:ccp(0, 1) velLimit:0];
  
  [self.obstacleArray addObject:robotTestC];
}

-(id)init
{
  if ((self = [super init])) {
    self.robot1Array = [[NSMutableArray alloc]init];
    for (int i=0; i<200; i++) {[self setStandardRobotWithArray:self.robot1Array group:1];}
    
    self.robot2Array = [[NSMutableArray alloc]init];
    for (int i=0; i<200; i++) {[self setStandardRobotWithArray:self.robot2Array group:2];}
    /*
    self.obstacleArray = [[NSMutableArray alloc]init];
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    CGPoint position;
    int widthSpace = winSize.width*0.2;
    int heightSpace = winSize.height*0.33;
    
    for (int i=0; i<3; i++) {
      if (i%2 == 0) {
        for (int j=0; j<2; j++) {
          position = ccp(widthSpace*(i+1.5), heightSpace*(j+1));
          [self setStandardObstacleWithPoint:position];
        }
      }else {
        for (int j=0; j<3; j++) {
          position = ccp(widthSpace*(i+1.5), heightSpace*(j+0.5));
          [self setStandardObstacleWithPoint:position];
        }
      }
    }
     */
  }
  
  return self;
}

@end
