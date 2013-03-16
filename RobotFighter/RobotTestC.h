//
//  RobotTestC.h
//  BasicCocos2D
//
//  Created by Ian Fan on 22/10/12.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ObjectiveChipmunk.h"
#import "chipmunk_unsafe.h"
#import "RobotTestSingleton.h"

typedef enum {
  CpShapeCircle,
  CpShapePoly,
} CpShape;

@interface RobotTestC : NSObject <ChipmunkObject>

@property int groupTag;

@property (nonatomic, retain) ChipmunkBody *chipmunkBody;
@property (nonatomic, retain) ChipmunkShape *chipmunkShape;
@property (nonatomic, retain) NSArray *chipmunkObjects;
@property (nonatomic, retain) CCSprite *mainSprite;

@property (nonatomic,retain) RobotTestC *targetSeekRobot;
@property (nonatomic,retain) RobotTestC *targetFleeRobot;

@property CpShape cpShape;
@property int touchedShapes;
@property float sizeWidth;
@property float sizeHeight;
@property float scaleAddAmount;
@property float scaleMultipleAmount;

@property CGPoint velocity;
@property CGPoint direction;

-(void)setChipmunkObjectsWithShapeStyle:(CpShape)cpShape_ mass:(float)mass_ sizeWidth:(int)sizeW_ sizeHeight:(int)sizeH_ positionX:(float)posX_ positionY:(float)posY_ elasticity:(float)elas_ friction:(float)fric_ collisionType:(NSString*)colliType_;
-(void)setChipmunkBodyVel:(CGPoint)vel_ velLimit:(float)velLimit_;
-(void)update;

-(void)addVisibilityToParent:(CCLayer*)parentLay;
-(void)removeVisibilityFromParent:(CCLayer*)parentLay;
@end
