//
//  Circle.m
//  CirclesPIMP
//
//  Created by Anton Krasnokutskiy on 12/8/14.
//  Copyright (c) 2014 Anton. All rights reserved.
//

#import "Circle.h"
#import "Geometry.h"

#define PI 3.14159265359

@interface Circle () {
    GLKVector4 circleColor;
    bool growing;
    float growSpeed;
    float killSpeed;
    float killX;
    float killY;
    float killRadius;
}

@end

@implementation Circle

@synthesize effect = _effect;
@synthesize position = _position;
@synthesize radius = _radius;
@synthesize readyToDelete = _readyToDelete;

- (id)initWithEffect:(GLKBaseEffect *)effect andColor:(GLKVector4)color andPosition:(GLKVector2)pos andSpeed:(float) speed andKillingSpeed:(float)killingSpeed {
    if (self = [super init]) {
        self.position = pos;
        self.effect = effect;
        self.radius = 0;
        self.readyToDelete = false;
        circleColor = color;
        growing = true;
        growSpeed = speed;
        killSpeed = killingSpeed;
        killRadius = 0;
    }
    return self;
}

- (void)updatePhysics {
    if (growing) {
        _radius += growSpeed;
    } else {
        if ([self isFullFilled])
            _readyToDelete = true;
        else {
            killRadius += killSpeed;
            _radius -= growSpeed;
        }
    }
}

- (bool)isFullFilled {
    return killRadius >= [Geometry distanceFromPointX:killX andY:killY toCircle:self] + 2 * _radius;
}

- (void)killCircleX:(float)x Y:(float)y {
    /*
        Add touched point
     */
    killX = x;
    killY = y;
    growing = false;
}

- (void)drawShadow {
    int vertexAmount = 360;
    GLKVector2 vertices[vertexAmount];
    //    (x, y) -> (cos(i / vertexAmount * PI) * radius + x ...)
    for (int i = 0; i < vertexAmount; i++) {
        double viX = cos((double) i / (double) vertexAmount * 2 * PI) * killRadius + killX;
        double viY = sin((double) i / (double) vertexAmount * 2 * PI) * killRadius + killY;
        double bigR = [Geometry distanceFromPointX:viX andY:viY toAX:_position.x AY:_position.y];
        if (bigR > _radius) {
            viX = (_radius / bigR) * (viX - _position.x) + _position.x;
            viY = (_radius / bigR) * (viY - _position.y) + _position.y;
        }
        viX -= killX;
        viY -= killY;
        vertices[i] = GLKVector2Make(viX, viY);
        //        NSLog(@"X = %.2f, Y = %.2f\n", vertices[i].x, vertices[i].y);
    }
    
    GLKVector2 triangleVertices[(vertexAmount - 2) * 3];
    for (int i = 1; i < vertexAmount - 1; i++) {
        int ind = i * 3;
        triangleVertices[ind] = vertices[0];
        triangleVertices[ind + 1] = vertices[i];
        triangleVertices[ind + 2] = vertices[i + 1];
    }
    GLKVector4 colorVertices[(vertexAmount - 2) * 3];
    for (int i = 0; i < (vertexAmount - 2) * 3; i++) {
        colorVertices[i] = GLKVector4Make(0, 0, 0, 0.06/.225);
    }
    
    self.effect.transform.modelviewMatrix = GLKMatrix4MakeTranslation(killX, killY, 0);
    [self.effect prepareToDraw];
    
    //    glEnable(GL_DEPTH_TEST);
    //    glEnable(GL_CULL_FACE);
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4,
                          GL_FLOAT, GL_FALSE, 0, colorVertices);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2,
                          GL_FLOAT, GL_FALSE, 0, triangleVertices);
    
    glDrawArrays(GL_TRIANGLES, 0, (vertexAmount - 2) * 3);
    
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    glDisableVertexAttribArray(GLKVertexAttribColor);
}

- (void)render {
    int vertexAmount = 360;
    
    GLKVector2 vertices[vertexAmount];
//    (x, y) -> (cos(i / vertexAmount * PI) * radius + x ...)
    for (int i = 0; i < vertexAmount; i++) {
        vertices[i] = GLKVector2Make(cos((double) i / (double) vertexAmount * 2 * PI) * _radius,
                                     sin((double) i / (double) vertexAmount * 2 * PI) * _radius);
//        NSLog(@"X = %.2f, Y = %.2f\n", vertices[i].x, vertices[i].y);
    }
    
    GLKVector2 triangleVertices[(vertexAmount - 2) * 3];
    for (int i = 1; i < vertexAmount - 1; i++) {
        int ind = i * 3;
        triangleVertices[ind] = vertices[0];
        triangleVertices[ind + 1] = vertices[i];
        triangleVertices[ind + 2] = vertices[i + 1];
    }
    GLKVector4 colorVertices[(vertexAmount - 2) * 3];
    for (int i = 0; i < (vertexAmount - 2) * 3; i++) {
        colorVertices[i] = circleColor;
    }
    
    self.effect.transform.modelviewMatrix = GLKMatrix4MakeTranslation(self.position.x, self.position.y, 0);
    [self.effect prepareToDraw];
    
    //    glEnable(GL_DEPTH_TEST);
    //    glEnable(GL_CULL_FACE);
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4,
                          GL_FLOAT, GL_FALSE, 0, colorVertices);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2,
                          GL_FLOAT, GL_FALSE, 0, triangleVertices);
    
    glDrawArrays(GL_TRIANGLES, 0, (vertexAmount - 2) * 3);
    
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    glDisableVertexAttribArray(GLKVertexAttribColor);
    
    if (!growing) {
        [self drawShadow];
    }
}

@end
