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
    // Points of trajectory in screen coordinate system
    NSMutableArray *points;
    
    // Colours to use for drawing
    NSMutableArray *colours;
    
    // Screen bounds
    float screenMaxX;
    float screenMaxY;
    // Lorenz coord system max/min values
    float lorenzMinX;
    float lorenzMaxX;
    float lorenzMinZ;
    float lorenzMaxZ;
    
    // Whether or not to draw colours
    bool shouldColour;
    
    int n; // Number of points drawn so far
    
    IBOutlet NSPanel *configSheet;
    IBOutlet NSButton *shouldColourCheckbox;
}

- (IBAction)sheetCancelAction:(id)sender;
- (IBAction)sheetOkAction:(id)sender;

@end
