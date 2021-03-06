//
//  Target.h
//  Turret
//
//  Created by Kirby Gee on 12/22/14.
//  Copyright (c) 2014 Kirby Gee - Stanford Univeristy. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#include "constants.h"

@interface Target : SKSpriteNode

@property (nonatomic) int pointsPerSecond;
- (void)runActionWithinFrame:(CGRect)frame;
- (CGPoint)step;

@end
