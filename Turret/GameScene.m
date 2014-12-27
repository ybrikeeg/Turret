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
         
         
         //check if locked is within heat sink rotation range
         NSLog(@"Rotation of turret: %f", SK_RADIANS_TO_DEGREES(angle));
         
         //calculate position at end of turret
         float pipeLength = PIPE_HEIGHT - ((BULLET_RECTANGLE_HEIGHT + BULLET_DIAMETER/2)/2);
         float x = cos(angle) * pipeLength;
         float y = sin(angle) * pipeLength;
         CGPoint tipOfPipe = CGPointMake(self.turret.position.x + x, self.turret.position.y + y);
         
         float theta = M_PI_2 - atanf((locked.position.y - tipOfPipe.y) / fabs(locked.position.x - tipOfPipe.x));
         NSLog(@"Theta: %f",SK_RADIANS_TO_DEGREES(theta));
         if (theta <= HEAT_SINK_ROTATION_LIMIT){
            //fire bullet
            Bullet *bullet = [[Bullet alloc] initWithAngle:angle withBulletType:kBulletHeatSeek];
            [self addChild:bullet];
            [bullet fireWithFrame:self.frame turretPosition:self.turret.position];
            
            [self.turret animatePipe];
         }
      }];
      
   }
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
         NSLog(@"Dist: %f", currDist);
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
      NSLog(@"DUDE");
      [bullet explode];
   }
   [target removeFromParent];
   NSLog(@"boom");
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
