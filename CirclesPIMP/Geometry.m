//
//  Geometry.m
//  CirclesPIMP
//
//  Created by Anton Krasnokutskiy on 12/8/14.
//  Copyright (c) 2014 Anton. All rights reserved.
//

#import "Geometry.h"

@implementation Geometry

+ (float)distanceFrom:(Circle *)a toAnother:(Circle *)b {
    return (float) sqrt((double) (a.position.x - b.position.x) * (a.position.x - b.position.x)
                        + (a.position.y - b.position.y) * (a.position.y - b.position.y))
                        - a.radius - b.radius;
}

+ (double)distanceFromPointX:(double)x andY:(double)y toAX:(double)ax AY:(double)ay {
    return (float) sqrt((double) (ax - x) * (ax - x) +
                        (ay - y) * (ay - y));
}

+ (float)distanceFromPointX:(float)x andY:(float)y toCircle:(Circle *)a {
    return (float) sqrt((double) (a.position.x - x) * (a.position.x - x) +
                        (a.position.y - y) * (a.position.y - y)) - a.radius;
}

+ (GPoint)touchPointFor:(Circle *)a and:(Circle *)b {

    float dst = [self distanceFrom:a toAnother:b] + a.radius + b.radius;
    GPoint t;
    t.x = a.position.x + (b.position.x - a.position.x) * a.radius / dst;
    t.y = a.position.y + (b.position.y - a.position.y) * a.radius / dst;
    return t;
}

@end
