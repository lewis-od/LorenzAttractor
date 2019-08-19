//
//  LorenzSolver.h
//  LorenzSaver
//
//  Created by Lewis O'Driscoll on 18/08/2019.
//  Copyright © 2019 Lewis O'Driscoll. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LorenzSolver : NSObject {
    // Time step and number of iterations
    float dt;
    int N;
}

@property float rho;
@property float sigma;
@property float beta;
// Coordinates
@property NSArray *x;
@property NSArray *y;
@property NSArray *z;

- (instancetype)initWithTMin:(float)tMin tMax:(float)tMax dt:(float)dt;
- (void)solve;

@end

NS_ASSUME_NONNULL_END
