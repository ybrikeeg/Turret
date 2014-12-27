//
//  GameScene.m
//  Turret
//
//  Created by Kirby Gee on 12/22/14.
//  Copyright (c) 2014 Kirby Gee - Stanford Univeristy. All rights reserved.
//

#import "GameScene.h"
#import "Turret.h"
#import "Target.h"
#import "Bullet.h"

@interface GameScene ()
@property (nonatomic, strong) Turret *turret;
@end
@implementation GameScene

-(void)didMoveToView:(SKView *)view {
   /* Setup your scene here */
   
   self.physicsWorld.contactDelegate = self;
   self.physicsWorld.gravity = CGVectorMake(0, 0);
   self.physicsWorld.speed = 1.0f;
   view.showsPhysics = YES;
   
   self.turret = [Turret node];
   self.turret.position = CGPointMake(CGRectGetMidX(self.frame), 0);
   [self addChild:self.turret];
   
   
   SKAction *targetWait = [SKAction waitForDuration: 2.0f];
   SKAction *targetSelector = [SKAction performSelector:@selector(createTarget) onTarget:self];
   [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[targetSelector, targetWait]]]];
   
   
}

- (void)createTarget
{
   Target *target = [[Target alloc] init];
   [self addChild:target];
   NSLog(@"Frame: %@", NSStringFromCGRect(self.view.frame));
   [target runActionWithinFrame:self.frame];
   
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
   /* Called when a touch begins */

   //do nothing if turret is in process of firing
   if ([self.turret hasActions]) return;
   
   for (UITouch *touch in touches) {
      CGPoint positionInScene = [touch locationInNode:self];
      
      Target *locked = [self calculateLockedTarget: positionInScene];
      
      float deltaX = positionInScene.x - self.turret.position.x;
      float deltaY = positionInScene.y - self.turret.position.y;
      float angle = atan2(deltaY, deltaX);
      float time = fabsf(angle - (self.turret.zRotation + M_PI_2)) * (TURRET_ROTATE_SPEED / (M_PI * 2));
      SKAction *rotation = [SKAction rotateToAngle:angle - SK_DEGREES_TO_RADIANS(90.0f) duration:time shortestUnitArc:YES];
      [self.turret runAction: rotation completion:^{

         float lockedAngle = [self getAngleFromTurretToPoint:locked.position angleOfTurret:angle];
         //NSLog(@"Theta: %f",SK_RADIANS_TO_DEGREES(theta));
         //NSLog(@"LockedAngle: %f",SK_RADIANS_TO_DEGREES(lockedAngle));
         
         if (fabs(lockedAngle) <= HEAT_SINK_ROTATION_LIMIT){
            
            //fire bullet
            Bullet *bullet = [[Bullet alloc] initWithAngle:angle withBulletType:kBulletHeatSeek];
            [self addChild:bullet];
            [bullet fireWithFrame:self.frame turretPosition:self.turret.position withAction:[self calculateLockedTargetPath: locked turretRotationAngle:angle touchPoint: positionInScene]];

            [self.turret animatePipe];
         }
      }];
      
   }
}

- (float)getAngleFromTurretToPoint:(CGPoint)pt angleOfTurret:(float)angle
{
   float pipeLength = PIPE_HEIGHT;
   float x = cos(angle) * pipeLength;
   float y = sin(angle) * pipeLength;
   CGPoint tipOfPipe = CGPointMake(self.turret.position.x + x, self.turret.position.y + y);
   
   float theta = M_PI_2 - atanf((pt.y - tipOfPipe.y) / fabs(pt.x - tipOfPipe.x));
   float lockedAngle = angle - (M_PI_2 - theta);
   if (angle > M_PI_2) lockedAngle = M_PI - angle - (M_PI_2 - theta);
   
   return lockedAngle;
}

- (SKAction *)calculateLockedTargetPath:(Target *)locked turretRotationAngle:(float)angle touchPoint:(CGPoint)touchPoint
{
   CGPoint nextPoint = CGPointZero;
   float targetTime = 0;
   float bulletTime = FLT_MAX;
   do {
      nextPoint = [locked step];
      
      //get time target takes to travel to next point
      targetTime = [self distance:nextPoint from:locked.position] / locked.pointsPerSecond;
      bulletTime = [self distance:nextPoint from:self.turret.position] / BULLET_SPEED;
      
      if (bulletTime < targetTime){
         CGPoint anchor = CGPointMake((touchPoint.x - self.turret.position.x)/2 + self.turret.position.x, (touchPoint.y - self.turret.position.y)/2 + self.turret.position.y);
         SKShapeNode *n = [SKShapeNode shapeNodeWithCircleOfRadius:3.0f];
         n.position = nextPoint;
         n.fillColor = [SKColor greenColor];
         [self addChild:n];
         
         SKShapeNode *n1 = [SKShapeNode shapeNodeWithCircleOfRadius:3.0f];
         n1.position = anchor;
         n1.fillColor = [SKColor yellowColor];
         [self addChild:n1];
         //calculate bezier path
         UIBezierPath *path = [UIBezierPath bezierPath];
         [path moveToPoint:self.turret.position];
         [path addQuadCurveToPoint:nextPoint controlPoint: anchor];
         
         SKShapeNode *pp = [SKShapeNode shapeNodeWithPath:path.CGPath];
         pp.fillColor = [SKColor clearColor];
         pp.strokeColor = [SKColor yellowColor];
         [self addChild:pp];
         
         SKAction *followline = [SKAction followPath:path.CGPath asOffset:NO orientToPath:YES duration:bulletTime];
         return followline;
      }
   } while (bulletTime > targetTime);
   
   return NULL;//this should never be called....hopefully
}

- (float)distance:(CGPoint)p1 from:(CGPoint)p2
{
   return (sqrt(pow((p1.x - p2.x), 2)) + sqrt(pow((p1.y - p2.y), 2)));
}

- (Target *)calculateLockedTarget:(CGPoint)touchPoint
{
   float closestDistance = FLT_MAX;
   Target *locked = nil;
   //find closest target end point to touch
   for (SKNode *node in self.children){
      if ([node isKindOfClass:[Target class]]){
         float currDist = [self distance:touchPoint from:node.position];
         if (currDist < closestDistance){
            closestDistance = currDist;
            locked = (Target *)node;
         }
      }
   }
   SKAction *a = [SKAction scaleTo:1.3f duration:0.2f];
   SKAction *b = [SKAction scaleTo:1.0f duration:0.2f];
   SKAction *sequence = [SKAction sequence:@[a,b]];
   [locked runAction:[SKAction repeatActionForever:sequence]];
   
   return locked;
}
-(void)update:(CFTimeInterval)currentTime {
   /* Called before each frame is rendered */

}

- (void)removeTarget:(Target *)target fromBullet:(Bullet *)bullet
{
   if (bullet.type == kBulletExplosion){
      [bullet explode];
   }
   [target removeFromParent];
}

/*
 *    Delegate method for any collisions. Handles all the logic
 *    for any type of collision. Category bit mask order is important
 *    for assigning firstBody/secondBody nodes
 */
- (void)didBeginContact:(SKPhysicsContact *)contact
{
   SKPhysicsBody *firstBody, *secondBody;
   if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask){
      firstBody = contact.bodyA;
      secondBody = contact.bodyB;
   } else{
      firstBody = contact.bodyB;
      secondBody = contact.bodyA;
   }
   
   if (firstBody.categoryBitMask == bulletCategory && secondBody.categoryBitMask == targetCategory){
      [self removeTarget:(Target *)secondBody.node fromBullet:(Bullet *)firstBody.node];
   }
}



@end
