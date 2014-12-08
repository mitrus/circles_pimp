//
//  Circle.h
//  CirclesPIMP
//
//  Created by Anton Krasnokutskiy on 12/8/14.
//  Copyright (c) 2014 Anton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface Circle : NSObject

@property (strong) GLKBaseEffect *effect;
@property GLKVector2 position;
@property GLKVector2 velocity;
@property float radius;
@property bool readyToDelete;

- (id)initWithEffect:(GLKBaseEffect *)effect andColor:(GLKVector4)color andPosition:(GLKVector2)pos andSpeed:(float)speed andKillingSpeed:(float)killingSpeed;

- (void)render;

- (void)updatePhysics;

- (bool)isFullFilled;

- (void)killCircleX:(float)x Y:(float)y;

@end
