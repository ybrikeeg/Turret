//
//  Bulet.h
//  Turret
//
//  Created by Kirby Gee on 12/22/14.
//  Copyright (c) 2014 Kirby Gee - Stanford Univeristy. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#include "constants.h"
#import "Target.h"

typedef enum {
   kBulletNormal,
   kBulletHeatSeek,
   kBulletExplosion,
} BulletType;

@interface Bullet : SKNode

@property (nonatomic) BulletType type;


- (id)initWithAngle:(float)angle withBulletType:(BulletType)bulletType;
- (int)getBulletHeight;
- (void)explode;
- (void)fireWithFrame:(CGRect)frame turretPosition:(CGPoint)turretPosition;
- (void)fireWithFrame:(CGRect)frame turretPosition:(CGPoint)turretPosition withAction:(SKAction *)action;

@end
