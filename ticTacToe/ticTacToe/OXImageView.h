//
//  OXImageView.h
//  ticTacToe
//
//  Created by xuchen on 2/5/15.
//  Copyright (c) 2015 __ChenXu__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OXImageView : UIImageView

@property (nonatomic) CGPoint initialPos;

-(void)toggleState;
@end
