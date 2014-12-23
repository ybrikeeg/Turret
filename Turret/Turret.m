//
//  Turret.m
//  Turret
//
//  Created by Kirby Gee on 12/22/14.
//  Copyright (c) 2014 Kirby Gee - Stanford Univeristy. All rights reserved.
//

#import "Turret.h"

@interface Turret ()
@property (nonatomic, strong) SKSpriteNode *pipe;
@end
@implementation Turret


-(id)init
{
   self = [super init];
   if(self) {
      SKSpriteNode *ring = [SKSpriteNode spriteNodeWithImageNamed:@"ring"];
      [self addChild:ring];
      
      self.pipe = [SKSpriteNode spriteNodeWithImageNamed:@"pipe"];
      self.pipe.position = CGPointMake(0, self.pipe.frame.size.height/2);
      [self addChild:self.pipe];
      
   }
   
   return self;
}

- (void)animatePipe
{

   SKAction *scaleTo = [SKAction scaleYTo:1.6f duration:0.1f];
   SKAction *scaleBack = [SKAction scaleYTo:1.0f duration:0.1f];
   [self.pipe runAction:[SKAction sequence:@[scaleTo, scaleBack]]];
}
@end
