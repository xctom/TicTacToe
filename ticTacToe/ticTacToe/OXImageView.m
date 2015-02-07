//
//  OXImageView.m
//  ticTacToe
//
//  Created by xuchen on 2/5/15.
//  Copyright (c) 2015 __ChenXu__. All rights reserved.
//

#import "OXImageView.h"

@implementation OXImageView

- (void)toggleState{
    self.userInteractionEnabled = !self.userInteractionEnabled;
    self.alpha = (self.alpha == 0.5)? 1 : 0.5;
    
    //when it is a player turn, show symbol animation
    if (self.userInteractionEnabled) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.transform = CGAffineTransformScale(self.transform, 1.5, 1.5);
                         }
                         completion:^(BOOL completed){
                             [UIView animateWithDuration:0.3
                                              animations:^{
                                                  self.transform = CGAffineTransformScale(self.transform, 0.66, 0.66);
                                              }
                                              completion:^(BOOL completed){
                                                  
                                              }
                              ];
                         }
         ];
    }
}

@end
