//
//  RobotFighterLayer.m
//  RobotFighter
//
//  Created by Ian Fan on 14/03/13.
//
//

#import "RobotFighterLayer.h"

#define GRABABLE_MASK_BIT (1<<31)
#define NOT_GRABABLE_MASK (~GRABABLE_MASK_BIT)

@implementation RobotFighterLayer

+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	RobotFighterLayer *layer = [RobotFighterLayer node];
	[scene addChild: layer];
	
	return scene;
}

#pragma mark - Collision

-(BOOL)beginCollision:(cpArbiter *)arbiter space:(ChipmunkSpace *)space {
  [_robotFighter beginCollision:arbiter space:space];
  
  return TRUE;
}

-(void)separateCollision:(cpArbiter *)arbiter space:(ChipmunkSpace *)space {
  [_robotFighter separateCollision:arbiter space:space];
}

#pragma mark - Draw
- (void)draw {
  if ( (_robotFighter.touchedUnit != nil && _robotFighter.touchedUnit.hp > 0) && (_robotFighter.touchingPoint.x != 0 && _robotFighter.touchingPoint.y != 0) ) {
    CGPoint point1 = _robotFighter.touchedUnit.sprite.position;
    CGPoint point2 = _robotFighter.touchingPoint;
    
    ccDrawColor4F(0,255,0,255);
    ccDrawLine(point1, point2);
  }
  
  [super draw];
}


#pragma mark - Touch Event

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [_robotFighter ccTouchesBegan:touches withEvent:event];
  
  for(UITouch *touch in touches){
    CGPoint point = [touch locationInView:[touch view]];
    point = [[CCDirector sharedDirector]convertToGL:point];
  }
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  [_robotFighter ccTouchesMoved:touches withEvent:event];
  
  for(UITouch *touch in touches){
    CGPoint point = [touch locationInView:[touch view]];
    point = [[CCDirector sharedDirector]convertToGL:point];
  }
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [_robotFighter ccTouchesEnded:touches withEvent:event];
  
	for(UITouch *touch in touches){
    CGPoint point = [touch locationInView:[touch view]];
    point = [[CCDirector sharedDirector]convertToGL:point];
  }
}

-(void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
  [self ccTouchEnded:touch withEvent:event];
}

#pragma mark -Update

-(void)update:(ccTime)dt {
  [_space step:dt];
  
  [_robotFighter update];
}

#pragma mark - SetupRobotFighter

-(void)setupRobotFighter {
  CGSize winSize = [CCDirector sharedDirector].winSize;
  
  _robotFighter = [[RobotFighter alloc]init];
  
  {
  RobotFighterUnit *unit = [[[RobotFighterUnit alloc]init]autorelease];
  unit.robotFighterUnitDelegate = _robotFighter;
  [unit setupSpriteWithParentLayer:self pngName:@"circleYellow.png"];
  [unit setupChipmunkObjectsWithParentSpace:_space IsCircleNotSquare:YES mass:1.0 width:50 height:50 position:ccp(winSize.width/4, winSize.height/4) elasticity:0.5 friction:0.5 collisionType:@"group1Type"];
  [unit setupFighterWithHp:100 speed:1 sight:100 attack:10 attackTime:30];
  [_robotFighter addUnit:unit];
  }
  
  {
  RobotFighterUnit *unit = [[[RobotFighterUnit alloc]init]autorelease];
  unit.robotFighterUnitDelegate = _robotFighter;
  [unit setupSpriteWithParentLayer:self pngName:@"circleYellow.png"];
  [unit setupChipmunkObjectsWithParentSpace:_space IsCircleNotSquare:YES mass:1.0 width:50 height:50 position:ccp(winSize.width/4, winSize.height*3/4) elasticity:0.5 friction:0.5 collisionType:@"group1Type"];
  [unit setupFighterWithHp:100 speed:1 sight:100 attack:10 attackTime:30];
  [_robotFighter addUnit:unit];
  }
  
  {
  RobotFighterUnit *unit = [[[RobotFighterUnit alloc]init]autorelease];
  unit.robotFighterUnitDelegate = _robotFighter;
  [unit setupSpriteWithParentLayer:self pngName:@"circleRed.png"];
  [unit setupChipmunkObjectsWithParentSpace:_space IsCircleNotSquare:YES mass:1.0 width:50 height:50 position:ccp(winSize.width*3/4, winSize.height/4) elasticity:0.5 friction:0.5 collisionType:@"group2Type"];
  [unit setupFighterWithHp:100 speed:1 sight:100 attack:10 attackTime:30];
  unit.chipmunkBody.angle = CC_DEGREES_TO_RADIANS(-180);
  [_robotFighter addUnit:unit];
  }
  
  {
  RobotFighterUnit *unit = [[[RobotFighterUnit alloc]init]autorelease];
  unit.robotFighterUnitDelegate = _robotFighter;
  [unit setupSpriteWithParentLayer:self pngName:@"circleRed.png"];
  [unit setupChipmunkObjectsWithParentSpace:_space IsCircleNotSquare:YES mass:1.0 width:50 height:50 position:ccp(winSize.width*3/4, winSize.height*3/4) elasticity:0.5 friction:0.5 collisionType:@"group2Type"];
  [unit setupFighterWithHp:100 speed:1 sight:100 attack:10 attackTime:30];
  unit.chipmunkBody.angle = CC_DEGREES_TO_RADIANS(-180);
  [_robotFighter addUnit:unit];
  }
}

#pragma mark - SeupChipmunk

-(void)setupChipmunkSpace {
  _space = [[ChipmunkSpace alloc]init];
  _space.gravity = cpv(0, 0);
  _space.iterations = 30;
  [_space addCollisionHandler:self typeA:@"group1Type" typeB:@"group2Type" begin:@selector(beginCollision:space:) preSolve:nil postSolve:nil separate:@selector(separateCollision:space:)];
}

-(void)setupMultiGrab {
  cpFloat grabForce = 1e5;
  cpFloat smoothing = cpfpow(0.3,60);
  
  _multiGrab = [[ChipmunkMultiGrab alloc]initForSpace:_space withSmoothing:smoothing withGrabForce:grabForce];
  _multiGrab.layers = GRABABLE_MASK_BIT;
  _multiGrab.grabFriction = grabForce*0.1;
  _multiGrab.grabRotaryFriction = 1e3;
  _multiGrab.grabRadius = 20.0;
  _multiGrab.pushMass = 1.0;
  _multiGrab.pushFriction = 0.7;
  _multiGrab.pushMode = FALSE;
}

-(void)setupDebugLayer {
  [self addChild:[CPDebugLayer debugLayerForSpace:_space.space options:nil] z:999];
}

#pragma mark - Init

-(id)init {
  if ((self = [super init])) {
    [self setupChipmunkSpace];
//    [self setupMultiGrab];
//    [self setupDebugLayer];
    
    [self setupRobotFighter];
    
    [self schedule:@selector(update:)];
    
    self.isTouchEnabled = YES;
  }
  
  return self;
}

- (void) dealloc {
  [_space release];
  [_multiGrab release];
  
	[super dealloc];
}

@end
