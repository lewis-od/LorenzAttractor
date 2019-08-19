//
//  LorenzSolver.m
//  LorenzSaver
//
//  Created by Lewis O'Driscoll on 18/08/2019.
//  Copyright © 2019 Lewis O'Driscoll. All rights reserved.
//

#import "LorenzSolver.h"

// Lorenz equations: dx_i/dt = f_i(x, y, z, t)
float fx(float xn, float yn, float zn, LorenzSolver *ctx) {
    return ctx.sigma * (yn - xn);
}

float fy(float xn, float yn, float zn, LorenzSolver *ctx) {
    return xn * (ctx.rho - zn) - yn;
}

float fz(float xn, float yn, float zn, LorenzSolver *ctx) {
    return xn * yn - ctx.beta * zn;
}

@implementation LorenzSolver

- (instancetype)initWithTMin:(float)tMin tMax:(float)tMax dt:(float)dt {
    self = [self init];
    
    self.beta = 8.0 / 3.0;
    // Rho is random float between 24 and 34
    int upperBound = 232783623;
    self.rho = 24.0 + (arc4random_uniform(upperBound) / (float)upperBound) * 10.0;
    self.sigma = 10.0 + (arc4random_uniform(upperBound) / (float)upperBound) * 5.0;
    
    self->N = (tMax - tMin) / dt; // Number of steps
    self->dt = dt;
    
    return self;
}

- (void)solve {
    NSMutableArray *xs = [NSMutableArray arrayWithCapacity:N];
    NSMutableArray *ys = [NSMutableArray arrayWithCapacity:N];
    NSMutableArray *zs = [NSMutableArray arrayWithCapacity:N];
    
    // Initial conditions (move to constructor?)
    xs[0] = @1.0;
    ys[0] = @1.0;
    zs[0] = @1.0;
    
    // Fourth order Runge-Kutta method
    for (int n = 0; n < (self->N - 1); n++) {
        float xn = [xs[n] floatValue];
        float yn = [ys[n] floatValue];
        float zn = [zs[n] floatValue];
        
        float k1_x = dt * fx(xn, yn, zn, self);
        float k1_y = dt * fy(xn, yn, zn, self);
        float k1_z = dt * fz(xn, yn, zn, self);
        
        float k2_x = dt * fx(xn + k1_x / 2, yn + k1_y / 2, zn + k1_z / 2, self);
        float k2_y = dt * fy(xn + k1_x / 2, yn + k1_y / 2, zn + k1_z / 2, self);
        float k2_z = dt * fz(xn + k1_x / 2, yn + k1_y / 2, zn + k1_z / 2, self);
        
        float k3_x = dt * fx(xn + k2_x / 2, yn + k2_y / 2, zn + k2_z / 2, self);
        float k3_y = dt * fy(xn + k2_x / 2, yn + k2_y / 2, zn + k2_z / 2, self);
        float k3_z = dt * fz(xn + k2_x / 2, yn + k2_y / 2, zn + k2_z / 2, self);
        
        float k4_x = dt * fx(xn + k3_x, yn + k3_y, zn + k3_z, self);
        float k4_y = dt * fy(xn + k3_x, yn + k3_y, zn + k3_z, self);
        float k4_z = dt * fz(xn + k3_x, yn + k3_y, zn + k3_z, self);
        
        float xNew = xn + (1.0 / 6.0) * (k1_x + 2 * k2_x + 2 * k3_x + k4_x);
        float yNew = yn + (1.0 / 6.0) * (k1_y + 2 * k2_y + 2 * k3_y + k4_y);
        float zNew = zn + (1.0 / 6.0) * (k1_z + 2 * k2_z + 2 * k3_z + k4_z);
        
        xs[n + 1] = [NSNumber numberWithFloat:xNew];
        ys[n + 1] = [NSNumber numberWithFloat:yNew];
        zs[n + 1] = [NSNumber numberWithFloat:zNew];
    }
    
    // Convert mutable arrays to immutable ones
    self.x = [xs copy];
    self.y = [ys copy];
    self.z = [zs copy];
}

@end
