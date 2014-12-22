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


@end
