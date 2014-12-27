//
//  constants.h
//  Turret
//
//  Created by Kirby Gee on 12/22/14.
//  Copyright (c) 2014 Kirby Gee - Stanford Univeristy. All rights reserved.
//

#ifndef Turret_constants_h
#define Turret_constants_h

static const int bulletCategory = 1 << 0;
static const int targetCategory = 1 << 1;

#define SK_DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) * 0.01745329252f) // PI / 180
#define SK_RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) * 57.29577951f) // PI * 180
#define BULLET_SPEED 800.0f //points per second
#define TURRET_ROTATE_SPEED 4.0f //time to rotate 360 degrees


#define PIPE_HEIGHT 100
#define HEAT_SINK_ROTATION_LIMIT (M_PI/8)

//bullet drawing
#define BULLET_RECTANGLE_HEIGHT 40
#define BULLET_DIAMETER 20
#endif
