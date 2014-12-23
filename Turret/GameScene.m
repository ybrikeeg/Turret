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

#define SK_DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) * 0.01745329252f) // PI / 180
#define SK_RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) * 57.29577951f) // PI * 180
#define BULLET_SPEED 35.0f
#define TURRET_ROTATE_SPEED 4.0f //time to rotate 360 degrees
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
   
   CGPoint start = CGPointMake(-target.frame.size.width, arc4random()%(int)self.frame.size.height);
   CGPoint end = CGPointMake(self.frame.size.width + target.frame.size.width, arc4random()%(int)self.frame.size.height);
   if (arc4random()%2 == 1){
      CGPoint temp = end;
      end = start;
      start = temp;
   }
   target.position = start;
   SKAction *move = [SKAction moveTo:end duration:7.0f];
   [target runAction:move completion:^{
      [target removeFromParent];
   }];
   
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
   
   //do nothing if turret is in process of firing
   if ([self.turret hasActions]) return;
   
    for (UITouch *touch in touches) {
       CGPoint positionInScene = [touch locationInNode:self];
       float deltaX = positionInScene.x - self.turret.position.x;
       float deltaY = positionInScene.y - self.turret.position.y;
       float angle = atan2(deltaY, deltaX);
       float time = fabsf(angle - (self.turret.zRotation + M_PI_2)) * (TURRET_ROTATE_SPEED / (M_PI * 2));
       NSLog(@"Time: %f", time);
       SKAction *rotation = [SKAction rotateToAngle:angle - SK_DEGREES_TO_RADIANS(90.0f) duration:time shortestUnitArc:YES];
       [self.turret runAction: rotation completion:^{
          //fire bullet
          Bullet *bullet = [[Bullet alloc] init];
          bullet.position = self.turret.position;
          [self addChild:bullet];
          [bullet.physicsBody applyImpulse:CGVectorMake(cosf(angle) * BULLET_SPEED, sinf(angle) * BULLET_SPEED)];

          [self.turret animatePipe];
       }];

    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

- (void)removeTarget:(Target *)target
{
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
      [self removeTarget:(Target *)secondBody.node];
   }
}



@end
