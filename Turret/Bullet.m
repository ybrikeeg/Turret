//
//  Bulet.m
//  Turret
//
//  Created by Kirby Gee on 12/22/14.
//  Copyright (c) 2014 Kirby Gee - Stanford Univeristy. All rights reserved.
//

#import "Bullet.h"

@interface Bullet ()
@property (strong, nonatomic) SKShapeNode *shape;
@property (nonatomic) BOOL isExploding;
@property (nonatomic) float angle;
@end
@implementation Bullet


- (id)initWithAngle:(float)angle withBulletType:(BulletType)bulletType
{
   self = [super init];
   if(self) {
      
      CGMutablePathRef circle = CGPathCreateMutable();
      CGPathMoveToPoint(circle, nil, 0, 0);
      CGPathAddLineToPoint(circle, nil, 0, BULLET_RECTANGLE_HEIGHT);
      CGPathAddArc(circle, nil, BULLET_DIAMETER/2, BULLET_RECTANGLE_HEIGHT, BULLET_DIAMETER/2, M_PI, 0, YES);
      CGPathAddLineToPoint(circle, nil, BULLET_DIAMETER, BULLET_RECTANGLE_HEIGHT);
      CGPathAddLineToPoint(circle, nil, BULLET_DIAMETER, 0);
      CGPathCloseSubpath(circle);
      
      self.shape = [SKShapeNode shapeNodeWithPath:circle centered:YES];
      self.shape.fillColor = [SKColor orangeColor];
      [self addChild:self.shape];

      self.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:self.shape.path];
      self.physicsBody.categoryBitMask = bulletCategory;
      self.physicsBody.contactTestBitMask = targetCategory;
      self.physicsBody.collisionBitMask = 0;
      self.physicsBody.usesPreciseCollisionDetection = YES;
      self.zRotation = angle - M_PI_2;
      self.type = bulletType;
      self.isExploding = NO;
      self.angle = angle;
      
      
   }
   
   return self;
}

- (void)fireWithFrame:(CGRect)frame turretPosition:(CGPoint)turretPosition
{
   //calculate position at end of turret
   float pipeLength = PIPE_HEIGHT - ([self getBulletHeight]/2);
   float x = cos(self.angle) * pipeLength;
   float y = sin(self.angle) * pipeLength;
   self.position = CGPointMake(turretPosition.x + x, turretPosition.y + y);
   
   //calculate the endpoint of the bullet animation, run action
   CGPoint bulletEndpoint = CGPointMake(turretPosition.x + frame.size.height * cos(self.angle), turretPosition.y + frame.size.height * sin(self.angle));
   float bulletActionTime = (sqrt(pow((bulletEndpoint.x - self.position.x), 2)) + sqrt(pow((bulletEndpoint.y - self.position.y), 2))) / BULLET_SPEED;
   [self runAction:[SKAction moveTo: bulletEndpoint duration:bulletActionTime] completion:^{
      [self removeFromParent];
   }];
}


/**
 * If the bullet type is explode, on collision with a target, the bullet will change its shape
 * to be circular, slowly stop, scale size, rotate/wait, scale down to 0 and then remove.
 *
 */
- (void)explode
{
   if (self.isExploding) return;
   self.isExploding = YES;
   [self.shape removeFromParent];
   [self removeAllActions];
   
   SKShapeNode *circle = [SKShapeNode shapeNodeWithCircleOfRadius:20.0f];
   circle.fillColor = [SKColor purpleColor];
   [self addChild:circle];
   
   self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:circle.frame.size.width/2];
   self.physicsBody.categoryBitMask = bulletCategory;
   self.physicsBody.contactTestBitMask = targetCategory;
   self.physicsBody.collisionBitMask = 0;

   float driftDistance = 40.0f;
   SKAction *drift = [SKAction moveByX:cos(self.angle) * driftDistance y:sin(self.angle) * driftDistance duration:0.5f];
   drift.timingMode = SKActionTimingEaseOut;
   [self runAction:drift];
   //scale up
   [self runAction:[SKAction sequence:@[[SKAction scaleTo:1.5f duration:1.3f], [SKAction waitForDuration:3.5f], [SKAction scaleTo:0.0f duration:1.0f]]] completion:^{
      [self removeFromParent];
   }];
}


/**
 * Returns the bullet height as defined by constants
 */
- (int)getBulletHeight
{
   return BULLET_RECTANGLE_HEIGHT + BULLET_DIAMETER/2;
}

@end
