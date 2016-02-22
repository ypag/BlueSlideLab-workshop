//
//  ViewControllerTracking.h
//  Blueslide1
//
//  Created by Priya Ganadas on 12/10/15.
//  Copyright © 2015 Priya Ganadas. All rights reserved.
//

#ifndef ViewControllerTracking_h
#define ViewControllerTracking_h


#endif /* ViewControllerTracking_h */

#import <UIKit/UIKit.h>

@ interface ViewControllerTracking : UIViewController<UIAlertViewDelegate>
{
    NSInteger count;
    NSInteger seconds;
    NSTimer *timer;
}
@end