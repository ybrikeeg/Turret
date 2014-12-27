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

#define GUIDE_WIDTH 4

-(id)init
{
   self = [super init];
   if(self) {
      SKSpriteNode *ring = [SKSpriteNode spriteNodeWithImageNamed:@"ring"];
      [self addChild:ring];
      
      self.pipe = [SKSpriteNode spriteNodeWithImageNamed:@"pipe"];
      self.pipe.position = CGPointMake(0, self.pipe.frame.size.height/2);
      [self addChild:self.pipe];
      
      SKShapeNode *leftZone = [SKShapeNode shapeNodeWithRect:CGRectMake(0, 0, GUIDE_WIDTH, 800)];
      leftZone.fillColor = [SKColor greenColor];
      leftZone.position = CGPointMake(self.pipe.position.x - GUIDE_WIDTH/2, self.pipe.position.y + self.pipe.frame.size.height/2);
      leftZone.zRotation = HEAT_SINK_ROTATION_LIMIT;
      [self addChild:leftZone];
      
      SKShapeNode *rightZone = [SKShapeNode shapeNodeWithRect:CGRectMake(0, 0, GUIDE_WIDTH, 800)];
      rightZone.fillColor = [SKColor greenColor];
      rightZone.position = CGPointMake(self.pipe.position.x - GUIDE_WIDTH/2, self.pipe.position.y + self.pipe.frame.size.height/2);
      rightZone.zRotation = -HEAT_SINK_ROTATION_LIMIT;
      [self addChild:rightZone];
      
   }
   
   return self;
}

- (void)animatePipe
{
   SKAction *scaleTo = [SKAction scaleYTo:1.6f duration:0.1f];
   SKAction *scaleBack = [SKAction scaleYTo:1.0f duration:0.1f];
   [self.pipe runAction:[SKAction sequence:@[scaleTo, scaleBack]]];
}

- (int)getPipeLength
{
   return self.pipe.frame.size.height;
}
@end
