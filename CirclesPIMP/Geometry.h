//
//  Geometry.h
//  CirclesPIMP
//
//  Created by Anton Krasnokutskiy on 12/8/14.
//  Copyright (c) 2014 Anton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Circle.h"

typedef struct {
    float x;
    float y;
} GPoint;

@interface Geometry : NSObject

+ (float)distanceFrom:(Circle *)a toAnother:(Circle *)b;

+ (float)distanceFromPointX:(float)x andY:(float)y toCircle:(Circle *)a;

+ (GPoint)touchPointFor:(Circle *)a and:(Circle *)b;

+ (double)distanceFromPointX:(double)x andY:(double)y toAX:(double)ax AY:(double)ay;


@end
