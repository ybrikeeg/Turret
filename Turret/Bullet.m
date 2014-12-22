//
//  Bulet.m
//  Turret
//
//  Created by Kirby Gee on 12/22/14.
//  Copyright (c) 2014 Kirby Gee - Stanford Univeristy. All rights reserved.
//

#import "Bullet.h"

@implementation Bullet

-(id)init
{
   self = [super init];
   if(self) {
      self = [Bullet spriteNodeWithImageNamed:@"bullet"];
      self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.frame.size.width/2];
      self.physicsBody.categoryBitMask = bulletCategory;
      self.physicsBody.contactTestBitMask = targetCategory;
      self.physicsBody.collisionBitMask = 0;
      self.physicsBody.usesPreciseCollisionDetection = YES;
   }
   
   return self;
}

@end
