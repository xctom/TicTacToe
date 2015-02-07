//
//  lineView.m
//  ticTacToe
//
//  Created by xuchen on 2/5/15.
//  Copyright (c) 2015 __ChenXu__. All rights reserved.
//

#import "lineView.h"

@implementation lineView

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, 4.0f);
    
    CGContextMoveToPoint(context, self.startPoint.x, self.startPoint.y); //start at this point
    
    CGContextAddLineToPoint(context, self.endPoint.x, self.endPoint.y); //draw to this point
    
    // and now draw the Path!
    CGContextStrokePath(context);
}

@end
