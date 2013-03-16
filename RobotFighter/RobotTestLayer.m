//
//  RobotTestLayer.m
//  BasicCocos2D
//
//  Created by Ian Fan on 22/10/12.
//
//

#import "RobotTestLayer.h"

#define GRABABLE_MASK_BIT (1<<31)
#define NOT_GRABABLE_MASK (~GRABABLE_MASK_BIT)

@implementation RobotTestLayer

+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	RobotTestLayer *layer = [RobotTestLayer node];
	[scene addChild: layer];
  
	return scene;
}

#pragma mark -
#pragma mark ChipmunkSpace

-(void)setSpace {
  _space = [[ChipmunkSpace alloc]init];
  _space.gravity = cpv(0, 0);
  _space.iterations = 30;
  [_space addCollisionHandler:self typeA:@"group1Type" typeB:@"group2Type" begin:@selector(beginCollision:space:) preSolve:nil postSolve:nil separate:nil];
}

-(BOOL)beginCollision:(cpArbiter *)arbiter space:(ChipmunkSpace *)space{
  // This macro gets the colliding shapes from the arbiter and defines variables for them.
  CHIPMUNK_ARBITER_GET_SHAPES(arbiter, group1RobotShape, group2RobotShape);
  CHIPMUNK_ARBITER_GET_BODIES(arbiter, group1RobotBody, group2RobotBody);
  
  RobotTestC *robot1 = group1RobotShape.data;
  RobotTestC *robot2 = group2RobotShape.data;
  
  [_space smartRemove:robot1];
  [_space smartRemove:robot2];
  
  [robot1 removeVisibilityFromParent:self];
  [robot2 removeVisibilityFromParent:self];
  
  [robot1 setChipmunkBodyVel:ccp(2, 0) velLimit:2];
  [robot2 setChipmunkBodyVel:ccp(-2, 0) velLimit:2];
  robot1.chipmunkBody.pos = ccp(-500, -500);
  robot2.chipmunkBody.pos = ccp(1500, -500);
  
  return TRUE;
}

#pragma mark -
#pragma mark Objects

-(void)setObjects {
  [self addObstacle];
  
  //detect retina display for sendingRobotRate
  float delayDuration = 0.08;
  if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0)) {
    delayDuration *= 2;
  }
  
  //keepSendingRobot1
  {
  group1Count = -1;
  CCDelayTime *delay = [CCDelayTime actionWithDuration:delayDuration];
  CCCallFunc *callFunc = [CCCallFunc actionWithTarget:self selector:@selector(addNewRobot1)];
  [self runAction:[CCRepeatForever actionWithAction:[CCSequence actions:delay,callFunc, nil]]];
  }
  
  //keepSendingRobot2
  {
  group2Count = 14;
  CCDelayTime *delay = [CCDelayTime actionWithDuration:delayDuration];
  CCCallFunc *callFunc = [CCCallFunc actionWithTarget:self selector:@selector(addNewRobot2)];
  [self runAction:[CCRepeatForever actionWithAction:[CCSequence actions:delay,callFunc, nil]]];
  }
}

-(void)addObstacle {
  for (RobotTestC *robot in [[RobotTestSingleton sharedInstance] obstacleArray]) {
    if ([_space contains:robot] == NO) {
      [robot addVisibilityToParent:self];
      [_space add:robot];
    }
  }
}

-(void)addNewRobot1 {
  CGSize winSize = [CCDirector sharedDirector].winSize;
  float space = 60;
  group1Count ++;
  if ((group1Count+0.5)*space>winSize.height) group1Count = 0;
  
  [self addNewRobotWithGroup:1 point:ccp(winSize.width*0.05, (group1Count+0.5)*space)];
}

-(void)addNewRobot2 {
  CGSize winSize = [CCDirector sharedDirector].winSize;
  float space = 60;
  group2Count --;
  if ((group2Count-0.5)*space<0) group2Count = 13;
  
  
  [self addNewRobotWithGroup:2 point:ccp(winSize.width*0.95, (group2Count-0.5)*space)];
}

-(void)addNewRobotWithGroup:(int)group_ point:(CGPoint)point_ {
  RobotTestSingleton *robotS = [RobotTestSingleton sharedInstance];
  NSMutableArray *robotArray;
  if (group_ == 1) {
    robotArray = robotS.robot1Array;
  }else if (group_ == 2) {
    robotArray = robotS.robot2Array;
  }
  
  for (RobotTestC *robot in robotArray) {
    if ([_space contains:robot] == NO) {
      robot.chipmunkBody.pos = point_;
      [robot addVisibilityToParent:self];
      [_space add:robot];
      
      break;
    }
  }
}

#pragma mark -
#pragma mark Update

-(void)update:(ccTime)dt {
  [_space step:dt];
  for (RobotTestC *robot in [[RobotTestSingleton sharedInstance] robot1Array]) {
    if ([_space contains:robot]) {
      [robot update];
    }
//    if (robot.isReady = NO) [robot update];
//    [robot update];
  }
  for (RobotTestC *robot in [[RobotTestSingleton sharedInstance] robot2Array]) {
    if ([_space contains:robot]) {
      [robot update];
    }
//    if (robot.isReady = NO) [robot update];
//    [robot update];
  }
}

#pragma mark -
#pragma mark Touch Event

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
{
  for(UITouch *touch in touches){
    CGPoint point = [touch locationInView:[touch view]];
    point = [[CCDirector sharedDirector]convertToGL:point];
//    [_multiGrab beginLocation:point];
  }
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
  for(UITouch *touch in touches){
    CGPoint point = [touch locationInView:[touch view]];
    point = [[CCDirector sharedDirector]convertToGL:point];
//    [_multiGrab updateLocation:point];
  }
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
{
	for(UITouch *touch in touches){
    CGPoint point = [touch locationInView:[touch view]];
    point = [[CCDirector sharedDirector]convertToGL:point];
//    [_multiGrab endLocation:point];
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    if (point.x < winSize.width/2) {
      [self addNewRobotWithGroup:1 point:point];
    }else if (point.x > winSize.width/2){
      [self addNewRobotWithGroup:2 point:point];
    }
  }
}

-(void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
  [self ccTouchEnded:touch withEvent:event];
}

#pragma mark -
#pragma mark ChipmunkMultiGrab

-(void)setMultiGrab {
  cpFloat grabForce = 1e5;
  cpFloat smoothing = cpfpow(0.3,60);
  
  _multiGrab = [[ChipmunkMultiGrab alloc]initForSpace:_space withSmoothing:smoothing withGrabForce:grabForce];
  _multiGrab.layers = GRABABLE_MASK_BIT;
  _multiGrab.grabFriction = grabForce*0.1;
  _multiGrab.grabRotaryFriction = 1e3;
  _multiGrab.grabRadius = 20.0;
  _multiGrab.pushMass = 1.0;
  _multiGrab.pushFriction = 0.7;
  _multiGrab.pushMode = TRUE;
}

#pragma mark -
#pragma mark CpDebugLayer

-(void)setDebugLayer {
  _debugLayer = [[CPDebugLayer alloc]initWithSpace:_space.space options:nil];
  [self addChild:_debugLayer z:999];
}

#pragma mark -
#pragma mark Init

-(id) init {
	if((self = [super init])) {
    self.isTouchEnabled = YES;
    
    [self setSpace];
    
    [self setObjects];
    
//    [self setMultiGrab];
    
//    [self setDebugLayer];
    
    [self schedule:@selector(update:)];
	}
	return self;
}

- (void) dealloc {
  for (RobotTestC *robot in [[RobotTestSingleton sharedInstance] robot1Array]) {
    [robot setChipmunkBodyVel:ccp(2, 0) velLimit:2];
    robot.chipmunkBody.pos = ccp(-500, -500);
  }
  
  for (RobotTestC *robot in [[RobotTestSingleton sharedInstance] robot2Array]) {
    [robot setChipmunkBodyVel:ccp(-2, 0) velLimit:2];
    robot.chipmunkBody.pos = ccp(1500, -500);
  }
  
  for (int i = [_space.bodies count]-1; i>=0; i--) {
    [_space removeBody:[_space.bodies objectAtIndex:i]];
  }
  for (int i = [_space.shapes count]-1; i>=0; i--) {
    [_space removeShape:[_space.shapes objectAtIndex:i]];
  }
  
  [_space release];
//  [_multiGrab release];
  [_debugLayer release];
  
	[super dealloc];
}

@end
