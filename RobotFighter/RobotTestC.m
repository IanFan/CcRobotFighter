//
//  RobotTestC.m
//  BasicCocos2D
//
//  Created by Ian Fan on 22/10/12.
//
//

#import "RobotTestC.h"

@implementation RobotTestC
@synthesize chipmunkBody = _chipmunkBody, chipmunkShape = _chipmunkShape, chipmunkObjects = _chipmunkObjects, mainSprite = _mainSprite, targetSeekRobot = _targetSeekRobot, targetFleeRobot = _targetFleeRobot, velocity = _velocity, direction = _direction;

#pragma mark -
#pragma mark Update

-(void)update {
  _direction = ccpNormalize(ccp(cosf(_chipmunkBody.angle),sinf(_chipmunkBody.angle)));
  _velocity = ccpMult(_direction, _chipmunkBody.velLimit);
  
  //ObstacleAvoidance
  [self obstacleAvoidance];
  
  //Seek
  [self seek];
  
  //Flee
//  [self flee];
  
  _chipmunkBody.vel = _velocity;
  _chipmunkBody.pos = ccpAdd(_chipmunkBody.pos, _velocity);
  _chipmunkBody.angle = ccpToAngle(_velocity);
  
  [self wrapAroundWithChipmunkBody:_chipmunkBody];
  
  _mainSprite.position = _chipmunkBody.pos;
  _mainSprite.rotation = -CC_RADIANS_TO_DEGREES(_chipmunkBody.angle);
}

-(void)seek {
  RobotTestSingleton *robotS = [RobotTestSingleton sharedInstance];
  NSArray *robotArray;
  CGPoint vel;
  if (self.groupTag == 1) {
    robotArray = robotS.robot2Array;
    vel = ccp(2, 0);
  }else if (self.groupTag == 2){
    robotArray = robotS.robot1Array;
    vel = ccp(-2, 0);
  }
  
  if (_targetSeekRobot == nil) {
    _chipmunkBody.vel = vel;
    for (RobotTestC *robot in robotArray) {
      float distance = ccpDistance(_chipmunkBody.pos, robot.chipmunkBody.pos);
      
      if (distance < 300) {
        if (_targetSeekRobot == nil) {
          _targetSeekRobot = robot;
        }else {
          float latestDistance = ccpDistance(_chipmunkBody.pos, _targetSeekRobot.chipmunkBody.pos);
          if (distance < latestDistance) _targetSeekRobot = robot;
        }
      }
      
    
    }
  }else {
    float latestDistance = ccpDistance(_chipmunkBody.pos, _targetSeekRobot.chipmunkBody.pos);
    if (latestDistance > 300) {
      _targetSeekRobot = nil;
      _chipmunkBody.vel = vel;
    }
  }
  
  if (_targetSeekRobot != nil) {
    CGPoint desiredSeekDirection = ccpNormalize(ccpSub(_targetSeekRobot.chipmunkBody.pos, _chipmunkBody.pos));
    CGPoint desiredSeekVelocity = ccpMult(desiredSeekDirection, _chipmunkBody.velLimit);
    
    CGPoint steeringSeekForce = ccpSub(desiredSeekVelocity, _velocity);
    steeringSeekForce = ccpMult(steeringSeekForce, 0.1f/_chipmunkBody.mass);
    
    _velocity = ccpAdd(_velocity, steeringSeekForce);
  }
  
}

-(void)flee {
//  RobotTestSingleton *robotS = [RobotTestSingleton sharedInstance];
  
  NSArray *fleeArray;
  CGPoint vel;
  if (_targetFleeRobot == nil) {
    if (self.groupTag == 1) {
      vel = ccp(2, 0);
    }else if (self.groupTag == 2){
      vel = ccp(-2, 0);
    }
  }
  
  if (_targetFleeRobot == nil) {
    for (RobotTestC *robot in fleeArray) {
      if (ccpDistance(_chipmunkBody.pos, robot.chipmunkBody.pos) < 300) {
        if (_targetFleeRobot != nil) {
          if (ccpDistance(_chipmunkBody.pos, robot.chipmunkBody.pos) < ccpDistance(_chipmunkBody.pos, _targetFleeRobot.chipmunkBody.pos)) {
            _targetFleeRobot = robot;
          }
        }else {
          _targetFleeRobot = robot;
        }
      }
    }
  }
  
  if (_targetFleeRobot != nil){
    CGPoint desiredFleeDirection = ccpNeg(ccpNormalize(ccpSub(_targetFleeRobot.chipmunkBody.pos, _chipmunkBody.pos)));
    CGPoint desiredFleeVelocity = ccpMult(desiredFleeDirection, _chipmunkBody.velLimit);
    
    CGPoint steeringFleeForce = ccpSub(desiredFleeVelocity, _velocity);
    steeringFleeForce = ccpMult(steeringFleeForce, 0.01f/_chipmunkBody.mass);
    
    float mainToTargetDis = ccpDistance(_chipmunkBody.pos, _targetFleeRobot.chipmunkBody.pos);
    if (mainToTargetDis < 200) {
      steeringFleeForce = ccpMult(steeringFleeForce, 4000.0f/mainToTargetDis);
    }
    
    _velocity = ccpAdd(_velocity, steeringFleeForce);
  }
}

-(void)obstacleAvoidance {
  float checkLength = 200.0f;
  RobotTestSingleton *robotS = [RobotTestSingleton sharedInstance];
  
  for (RobotTestC *obstacle in robotS.obstacleArray) {
    CGPoint difference = ccpSub(obstacle.chipmunkBody.pos, _chipmunkBody.pos);
    float dotProduct = ccpDot(difference, _direction);
    
    if (dotProduct > 0) {
      CGPoint ray = ccpMult(_direction, checkLength);
      CGPoint projection = ccpMult(_direction, dotProduct);
      float dis = ccpDistance(projection, difference);
      
      if (dis < (0.5*obstacle.sizeWidth + self.sizeWidth) && ccpLength(projection) < ccpLength(ray)) {
        CGPoint force = ccpMult(_direction, self.chipmunkBody.velLimit);
        float forceRadians = ccpToAngle(force);
        forceRadians += ccpAngleSigned(difference, _velocity);
        force = ccpMult(ccp(cosf(forceRadians), sinf(forceRadians)), ccpLength(force));
        force = ccpMult(force,(1- ccpLength(projection)/ccpLength(ray)));
        _chipmunkBody.force = force;
        _velocity = ccpAdd(_velocity, force);
        _velocity = ccpMult(_velocity, ccpLength(projection)/ccpLength(ray));
//        _velocity = ccpMult(_velocity, 0.2f/_chipmunkBody.mass);
      }
    }
    
  }
}

#pragma mark -
#pragma mark Tool

-(float)randfrom:(float)start to:(float)end {
  return CCRANDOM_0_1()*(end-start) + start;
}

-(void)wrapAroundWithChipmunkBody:(ChipmunkBody*)cpBody {
  CGSize winSize = [CCDirector sharedDirector].winSize;
  if (cpBody.pos.x>winSize.width ) cpBody.pos = ccp(cpBody.pos.x-winSize.width, cpBody.pos.y);
  if (cpBody.pos.x<0             ) cpBody.pos = ccp(cpBody.pos.x+winSize.width, cpBody.pos.y);
  if (cpBody.pos.y>winSize.height) cpBody.pos = ccp(cpBody.pos.x, cpBody.pos.y-winSize.height);
  if (cpBody.pos.y<0             ) cpBody.pos = ccp(cpBody.pos.x, cpBody.pos.y+winSize.height);
}

-(void)wrapAroundWithSprite:(CCSprite*)sprite {
  CGSize winSize = [CCDirector sharedDirector].winSize;
  if (sprite.position.x>winSize.width ) sprite.position = ccp(sprite.position.x-winSize.width, sprite.position.y);
  if (sprite.position.x<0             ) sprite.position = ccp(sprite.position.x+winSize.width, sprite.position.y);
  if (sprite.position.y>winSize.height) sprite.position = ccp(sprite.position.x, sprite.position.y-winSize.height);
  if (sprite.position.y<0             ) sprite.position = ccp(sprite.position.x, sprite.position.y+winSize.height);
}

#pragma mark -
#pragma mark Visibility

-(void)addVisibilityToParent:(CCLayer*)parentLay {
  if ([[parentLay children] containsObject:_mainSprite] == NO) [parentLay addChild:_mainSprite];
}

-(void)removeVisibilityFromParent:(CCLayer*)parentLay {
  [parentLay removeChild:_mainSprite cleanup:NO];
}

#pragma mark -
#pragma mark Set

-(void)setChipmunkBodyVel:(CGPoint)vel_ velLimit:(float)velLimit_ {
  _chipmunkBody.vel = vel_;
  _chipmunkBody.angle = ccpToAngle(vel_);
  _chipmunkBody.velLimit = velLimit_;
  
  if (self.mainSprite != nil) {
    self.mainSprite.rotation = -CC_RADIANS_TO_DEGREES(_chipmunkBody.angle);
  }
}

-(void)setChipmunkObjectsWithShapeStyle:(CpShape)cpShape_ mass:(float)mass_ sizeWidth:(int)sizeW_ sizeHeight:(int)sizeH_ positionX:(float)posX_ positionY:(float)posY_ elasticity:(float)elas_ friction:(float)fric_ collisionType:(NSString*)colliType_ {
  self.scaleAddAmount = 0;
  self.scaleMultipleAmount = 1;
  
  self.sizeWidth = sizeW_;
  self.sizeHeight = sizeH_;
  
  self.cpShape = cpShape_;
  
  ChipmunkBody *body;
  ChipmunkShape *shape;
  cpFloat moment;
  
  switch (cpShape_) {
    case CpShapeCircle:{
      moment = cpMomentForCircle(mass_, 0, sizeW_, cpv(0.0f, 0.0f));
      body = [[ChipmunkBody alloc] initWithMass:mass_ andMoment:moment];
      shape = [ChipmunkCircleShape circleWithBody:body radius:(0.5*sizeW_) offset:CGPointMake(0, 0)];
      break;
    }
    case CpShapePoly:{
      moment = cpMomentForBox(mass_, sizeW_, sizeH_);
      body = [[ChipmunkBody alloc]initWithMass:mass_ andMoment:moment];
      shape = [ChipmunkPolyShape boxWithBody:body width:sizeW_ height:sizeH_];
      break;
    }
      /*
       case ShapeStyleStaticCircle:{
       //      moment = cpMomentForCircle(mas, sizeW, sizeH, cpv(0.0f, 0.0f));
       body = [[ChipmunkBody alloc]initStaticBody];
       shape = [ChipmunkStaticCircleShape circleWithBody:body radius:0.5*sizeW offset:CGPointZero];
       break;
       }
       */
      
    default:
      break;
  }
  
  [body setPos:cpv(posX_, posY_)];
  [shape setElasticity:elas_];
  [shape setFriction:fric_];
  [shape setCollisionType:colliType_];
  [shape setData:self];
  
  NSArray *cpArray = [[NSArray alloc]initWithObjects:body,shape, nil];
  
  self.chipmunkObjects = cpArray;
  self.chipmunkBody = body;
  self.chipmunkShape = shape;
  
  [body release];
  [cpArray release];
}

#pragma mark -
#pragma mark Init

-(id)init
{
  if ((self = [super init])) {
  }
  
  return self;
}

-(void)dealloc {
  self.chipmunkBody = nil;
  self.chipmunkShape = nil;
  self.chipmunkObjects = nil;
  self.mainSprite = nil;
  
  [super dealloc];
}

@end
