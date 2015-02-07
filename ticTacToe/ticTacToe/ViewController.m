//
//  ViewController.m
//  ticTacToe
//
//  Created by xuchen on 2/5/15.
//  Copyright (c) 2015 __ChenXu__. All rights reserved.
//

#import "ViewController.h"
#import "OXImageView.h"
#import "myView.h"
#import "lineView.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet OXImageView *XImageView;
@property (weak, nonatomic) IBOutlet OXImageView *OImageView;
@property (strong, nonatomic) NSMutableArray* viewArray;
@property (nonatomic) NSInteger emptyCnt;//number of empty UIViews

@property (weak, nonatomic) IBOutlet UIView *infoAlertView;
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

- (IBAction)myAlertDismiss:(id)sender;

- (IBAction)helpButtonTapDown:(id)sender;

@end

@implementation ViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark init
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //put all UIView into an array
    self.viewArray = [[NSMutableArray alloc] init];
    for (NSInteger i = 1; i <= 9; i++) {
        myView* v = (myView*)[self.view viewWithTag:i];
        [self.viewArray addObject:v];
    }
    
    //save original place of X and O
    self.OImageView.initialPos = self.OImageView.center;
    self.XImageView.initialPos = self.XImageView.center;
    
    //add gestur recognizer for X and O
    [self addGesturRecognizer];
    
    //init
    [self initGame];
}

/**
 *  init the game:
 *  restore X and O state
 *  clean all UIViews
 */
-(void)initGame{
    //set empty number of UIview
    self.emptyCnt = 9;
    
    //set inti state of X and O
    [self.XImageView setUserInteractionEnabled:YES];
    [self.OImageView setUserInteractionEnabled:NO];
    [self.XImageView setAlpha:1.0];
    [self.OImageView setAlpha:0.5];
    
    //cleanUp UIViews
    for (myView* v in self.viewArray) {
        //default winner tag
        v.playerTag = 0;
        
        for (UIView* subView in v.subviews) {
            [subView removeFromSuperview];
        }
    }
    
    //remove lineView
    if ([self.view viewWithTag:100]) {
        [[self.view viewWithTag:100] removeFromSuperview];
    }
}

-(void) addGesturRecognizer{
    //add panGestureRecognizer for X
    UIPanGestureRecognizer* XPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [XPanRecognizer setDelegate:self];
    [self.XImageView addGestureRecognizer:XPanRecognizer];
    
    //add panGestureRecognizer for O
    UIPanGestureRecognizer* OPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [OPanRecognizer setDelegate:self];
    [self.OImageView addGestureRecognizer:OPanRecognizer];
}

#pragma mark handle function
-(void)handlePan:(UIPanGestureRecognizer *)sender{
    OXImageView* moving = (OXImageView*)[sender view];
    
    //when start to drag, play sound
    if (sender.state == UIGestureRecognizerStateBegan) {
        //play sound
        [self playSound:@"startDrag"];
    }
    
    if (sender.state == UIGestureRecognizerStateChanged) {
        //get offset and move the target view
        
        CGPoint offset = [sender translationInView:self.view];
        [moving setCenter:CGPointMake(moving.center.x + offset.x, moving.center.y + offset.y)];
        [sender setTranslation:CGPointMake(0, 0) inView:self.view];
        
    }else if (sender.state == UIGestureRecognizerStateEnded){
        //when pan ended, determine the intersect of moving view and the UIView
        
        BOOL needAnimation = YES;//variable for judge if we need the go back animation
        
        //chekc if we can put the image into any intersected cell
        for (UIView *v in self.viewArray) {
            if (CGRectIntersectsRect(v.frame, moving.frame)) {
                //if this view is occupied
                    //continue
                //else put image into this view
                    //set needAnimation to false
                if ([[v subviews] count] == 0) {
                    // > 0 for occupied
                    needAnimation = NO;
                    UIImageView* tempImage = [[UIImageView alloc] initWithImage:[moving image]];
                    
                    //resize the Image to the same size as the target UIView
                    CGRect frame = tempImage.frame;
                    frame.size.width = v.frame.size.width;
                    frame.size.height = v.frame.size.height;
                    tempImage.frame = frame;
                    
                    //add image to the UIView
                    [v addSubview:tempImage];
                    
                    //play sound
                    [self playSound:@"snap"];
                    
                    //toggle state for X and O
                    [self.OImageView toggleState];
                    [self.XImageView toggleState];
                    
                    //set player tag to the UIView and reduce the emptyCnt
                    ((myView*)v).playerTag = moving.tag;
                    self.emptyCnt--;
                
                    //check for win or draw
                    [self checkResult:moving.tag];
                    
                    break;
                }
            }
        }
        
        if(needAnimation){
            //use animation to go back
            
            //play sound
            [self playSound:@"goBack"];
            
            [UIView animateWithDuration:2.0
                             animations:^{
                                moving.center = moving.initialPos;
                             }
                             completion:^(BOOL completed){
                                 NSLog(@"Go back!");
                             }
             ];
            
        }else{
            //go back directly
        }
        
    }
    
 
}

#pragma mark check for the result
-(void) checkResult: (NSInteger) tag{
    //check if imageView with tag is win
    //if so
        //go to draw a line and popUp a win window
    //else
        //check if it is a draw
        //if so
            //popUp a draw window
        //else do nothing
    if ([self getPlayerTag:0] == tag && [self getPlayerTag:1] == tag && [self getPlayerTag:2] == tag) {
        [self win:tag startIndex:0 endIndex:2];
    }else if ([self getPlayerTag:3] == tag && [self getPlayerTag:4] == tag && [self getPlayerTag:5] == tag){
        [self win:tag startIndex:3 endIndex:5];
    }else if ([self getPlayerTag:6] == tag && [self getPlayerTag:7] == tag && [self getPlayerTag:8] == tag){
        [self win:tag startIndex:6 endIndex:8];
    }else if ([self getPlayerTag:0] == tag && [self getPlayerTag:3] == tag && [self getPlayerTag:6] == tag){
        [self win:tag startIndex:0 endIndex:6];
    }else if ([self getPlayerTag:1] == tag && [self getPlayerTag:4] == tag && [self getPlayerTag:7] == tag){
        [self win:tag startIndex:1 endIndex:7];
    }else if ([self getPlayerTag:2] == tag && [self getPlayerTag:5] == tag && [self getPlayerTag:8] == tag){
        [self win:tag startIndex:2 endIndex:8];
    }else if ([self getPlayerTag:0] == tag && [self getPlayerTag:4] == tag && [self getPlayerTag:8] == tag){
        [self win:tag startIndex:0 endIndex:8];
    }else if ([self getPlayerTag:2] == tag && [self getPlayerTag:4] == tag && [self getPlayerTag:6] == tag){
        [self win:tag startIndex:2 endIndex:6];
    }else if (self.emptyCnt == 0) {
        [self draw];
    }
}

/**
 *  return playerTag of the UIView in the given index in the viewArray
 */
-(NSInteger) getPlayerTag: (NSInteger)index{
    
    if (index < 9 && index >= 0) {
        myView* v = (myView*)[self.viewArray objectAtIndex:index];
        return v.playerTag;
    }
    
    return -1;
}

-(void) win: (NSInteger) winnerTag startIndex:(NSInteger)start endIndex:(NSInteger)end{
    
    //draw a line from viewArray[start].center to viewArray[end]
    CGPoint startPoint = ((UIView*)[self.viewArray objectAtIndex:start]).center;
    CGPoint endPoint = ((UIView*)[self.viewArray objectAtIndex:end]).center;
    
    lineView* line = [[lineView alloc] init];
    
    line.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
    
    //resize the Image to the same size as the grid
    UIView* grid = [self.view viewWithTag:12];
    
    CGRect frame = line.frame;
    frame.size.width = grid.frame.size.width;
    frame.size.height = grid.frame.size.height + grid.frame.origin.y;// add y offset of the grid
    line.frame = frame;
    
    //set tag for delete
    line.tag = 100;
    
    //set start point and end point of the line
    [line setStartPoint:startPoint];
    [line setEndPoint:endPoint];
    
    //add view to self.view calls line.drawRect automatically
    [self.view addSubview:line];
    
    //set both imageView to be disabled
    [self.XImageView setUserInteractionEnabled:NO];
    [self.OImageView setUserInteractionEnabled:NO];
    
    //popUp a window to show the result of the game;
    NSString* winner = (winnerTag == 10)?@"X":@"O";
    
    //play sound
    [self playSound:@"win"];
    
    [self showGameOverAlert:[[NSString alloc] initWithFormat:@"%@ wins!",winner]];

}

-(void) draw{
    //play sound
    [self playSound:@"draw"];
    
    [self showGameOverAlert:@"Draw!"];
}

#pragma mark alertViews
-(void)showGameOverAlert:(NSString*)theMessage{
    
    UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Game Over"
                                                 message:theMessage
                                                delegate:self
                                       cancelButtonTitle:@"New Game" otherButtonTitles:nil, nil];
    //tag 15 for GameOver AlertView
    av.tag = 15;
    [av show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 15) {
        [self initGame];
    }
}

#pragma mark info button
- (IBAction)helpButtonTapDown:(id)sender {
    
    //go down to the center
    [UIView animateWithDuration:1.0
                     animations:^{
                         UIView* grid = [self.view viewWithTag:12];
                         self.infoAlertView.center = grid.center;
                     }
                     completion:^(BOOL completed){
                     }
     ];
    

}

- (IBAction)myAlertDismiss:(id)sender {
    
    //go back to original palce
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.infoAlertView.center = CGPointMake(self.infoAlertView.center.x, -self.infoAlertView.frame.size.height);
                     }
                     completion:^(BOOL completed){
                     }
     ];
    
}

#pragma audio
-(void) playSound:(NSString*) soundPath{
    NSString *path = [[NSBundle mainBundle] pathForResource:soundPath ofType:@"mp3"];
    self.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:
                        [NSURL fileURLWithPath:path] error:NULL];
    [self.audioPlayer play];
}
@end
