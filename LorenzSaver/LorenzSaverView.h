//
//  LorenzSaverView.h
//  LorenzSaver
//
//  Created by Lewis O'Driscoll on 18/08/2019.
//  Copyright © 2019 Lewis O'Driscoll. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import "LorenzSolver.h"

@interface LorenzSaverView : ScreenSaverView {
    LorenzSolver *solver;
}

@end
