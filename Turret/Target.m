//
//  Target.m
//  Turret
//
//  Created by Kirby Gee on 12/22/14.
//  Copyright (c) 2014 Kirby Gee - Stanford Univeristy. All rights reserved.
//

#import "Target.h"

@implementation Target

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
   }
   
   return self;
}

- (void)runActionWithinFrame:(CGRect)frame
{
   CGPoint start = CGPointMake(-self.frame.size.width, arc4random()%(int)self.frame.size.height);
   CGPoint end = CGPointMake(frame.size.width + self.frame.size.width, arc4random()%(int)frame.size.height);
   if (arc4random()%2 == 1){
      CGPoint temp = end;
      end = start;
      start = temp;
   }
   self.position = start;
   SKAction *move = [SKAction moveTo:end duration:7.0f];
   [self runAction:move completion:^{
      [self removeFromParent];
   }];
}
@end
