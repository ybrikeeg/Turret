//
//  Target.m
//  Turret
//
//  Created by Kirby Gee on 12/22/14.
//  Copyright (c) 2014 Kirby Gee - Stanford Univeristy. All rights reserved.
//

#import "Target.h"

@interface Target ()
@property (nonatomic) int stepCount;
@property (nonatomic) CGVector unitVector;
@end
@implementation Target

#define STEP_SIZE 5
-(id)init
{
   self = [super init];
   if(self) {
      self = [Target spriteNodeWithImageNamed:@"turretRing"];
      self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.frame.size.width/2];
      self.physicsBody.categoryBitMask = targetCategory;
      self.physicsBody.contactTestBitMask = bulletCategory;
      self.physicsBody.collisionBitMask = 0;
      self.physicsBody.usesPreciseCollisionDetection = YES;
      self.stepCount = 0;
   }
   
   return self;
}

- (CGPoint)step
{
   //calculate the position of the target 10 points forward
   self.stepCount++;
   
   return CGPointMake(self.position.x + self.stepCount * self.unitVector.dx * STEP_SIZE, self.position.y + self.stepCount * self.unitVector.dy* STEP_SIZE);
}

- (void)runActionWithinFrame:(CGRect)frame
{
   CGPoint start = CGPointMake(-self.frame.size.width, arc4random()%(int)frame.size.height);
   CGPoint end = CGPointMake(frame.size.width + self.frame.size.width, arc4random()%(int)frame.size.height);
   if (arc4random()%2 == 1){
      CGPoint temp = end;
      end = start;
      start = temp;
   }
   NSLog(@"FRAME: %@", NSStringFromCGRect(frame));
   self.position = start;
   float dx = end.x - start.x;
   float dy = end.y - start.y;
   SKAction *move = [SKAction moveByX:dx y:dy duration:14.0f];
   [self runAction:move completion:^{
      [self removeFromParent];
   }];
   
   float hyp = (sqrt(pow(dx, 2) + pow(dy, 2)));
   self.unitVector = CGVectorMake(dx / hyp, dy / hyp);
   self.pointsPerSecond = hyp / 14.0f;
}
@end
