//
//  ViewControllerPractice.m
//  Blueslide1
//
//  Created by Priya Ganadas on 2/5/16.
//  Copyright © 2016 Priya Ganadas. All rights reserved.
//

#import "ViewControllerPractice.h"
#import <AVFoundation/AVFoundation.h>
#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/types_c.h>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/videoio/cap_ios.h>
#import "CMT.h"

#define RATIO  640.0/1024.0

using namespace cv;
using namespace std;

typedef enum {
    
    CMT_TRACKER,
    
}TrackType;

@interface ViewControllerPractice ()<CvVideoCameraDelegate>
{
    CGPoint rectLeftTopPoint;
    CGPoint rectRightDownPoint
    ;
    
    TrackType trackType;
    
    // CT Tracker
    
    cv::Rect selectBox;
    cv::Rect initCTBox;
    cv::Rect box;
    bool beginInit;
    bool startTracking;
    
    // CMT Tracker
    cmt::CMT *cmtTracker;
    
}


//@interface ViewControllerPractice ()
@property (weak, nonatomic) IBOutlet UILabel *introText;

//@property (weak, nonatomic) IBOutlet UILabel *introText; // Text field that instructs observer how to select the performer
//@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

//@property (weak, nonatomic) IBOutlet UIButton *nextButton; //Button that says "Begin"
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

//@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic,strong) CvVideoCamera *videoCamera;
@end

@implementation ViewControllerPractice

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    //int view_width = 568;
    int view_width = self.view.frame.size.width;
    cout<< "width is : " << view_width <<endl;
    int view_height = 480*view_width/640; // Work out the view-height assuming 640x480 input
    //int view_offset = (self.view.frame.size.height - view_height)/2;
    
    //Setting up the imageview here
    self.imageView.frame = CGRectMake(0,0, view_width, view_height);
    
    //Setting up the Video Camera using cvvideocamera class
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.imageView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    //self.videoCamera.defaultFPS = 30;
    [self.videoCamera start];
    
    
    rectLeftTopPoint = CGPointZero;
    rectRightDownPoint = CGPointZero;
    
    beginInit = false;
    startTracking = false;
    
    self.introText.textColor = [UIColor whiteColor];
    self.introText.tag = 1001;
    
    [self.nextButton setTitle:@"Begin!" forState:UIControlStateNormal];
    [_nextButton addTarget:self action:@selector(aMethod:) forControlEvents:UIControlEventTouchUpInside];
    
    
    trackType = CMT_TRACKER;
}



- (void)aMethod:(UIButton*)button
{
    NSLog(@"Button  clicked."); // Output log if button is clicked
    UILabel *tempLabel = (UILabel *)[self.view viewWithTag:1001];
    [tempLabel setHidden: YES];
    tempLabel.hidden = YES;
    [(UIButton*) button setHidden:YES]; //Hide the button after it is clicked
    UIImageView *PlayerPreview=[[UIImageView alloc]initWithFrame:CGRectMake(200, 130, 700, 670)];
    PlayerPreview.tag = 1003;
    PlayerPreview.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"playerGuide" ofType:@"png"]];
    [self.view addSubview:PlayerPreview];
    
    
    UILabel* PlayerGuide = [[UILabel alloc] initWithFrame:CGRectMake(200, 30, 250, 200)];
    PlayerGuide.tag = 1002;
    PlayerGuide.numberOfLines = 3;
    PlayerGuide.textAlignment = NSTextAlignmentCenter;
    [PlayerGuide setFont:[UIFont fontWithName:@"Comic Sans MS" size:27]];
    PlayerGuide.text = @" Draw a square around your Friend ";
    PlayerGuide.textColor = [UIColor whiteColor];
    [self.view addSubview:PlayerGuide];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reset
{
    startTracking = false;
    beginInit = false;
    
    rectLeftTopPoint.x = 0;
    rectRightDownPoint.x = 0;
}

- (IBAction)CMT:(id)sender
{
    trackType = CMT_TRACKER;
    [self reset];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    startTracking = false;
    beginInit = false;
    UITouch *aTouch  = [touches anyObject];
    rectLeftTopPoint = [aTouch locationInView:self.imageView];
    
    NSLog(@"touch in :%f,%f",rectLeftTopPoint.x,rectLeftTopPoint.y);
    rectRightDownPoint = CGPointZero;
    selectBox = cv::Rect(rectLeftTopPoint.x * RATIO,rectLeftTopPoint.y * RATIO,0,0);
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch  = [touches anyObject];
    rectRightDownPoint = [aTouch locationInView:self.imageView];
    
    //NSLog(@"touch move :%f,%f",rectRightDownPoint.x,rectRightDownPoint.y);
    
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch  = [touches anyObject];
    rectRightDownPoint = [aTouch locationInView:self.imageView];
    
    NSLog(@"touch end :%f,%f",rectRightDownPoint.x,rectRightDownPoint.y);
    selectBox.width = abs(rectRightDownPoint.x * RATIO - selectBox.x);
    selectBox.height = abs(rectRightDownPoint.y * RATIO - selectBox.y);
    beginInit = true;
    initCTBox = selectBox;
    
    //Hide the instruction text after rectangle is drawn
    NSLog(@"Rectangle Drawn.");
    UILabel *tempLabel = (UILabel *)[self.view viewWithTag:1002];
    [tempLabel setHidden: YES];
    tempLabel.hidden = YES;
    
    //Hide the guiding image after rectangle is drawn
    UIImageView *tempView = (UIImageView *)[self.view viewWithTag:1003];
    [tempView setHidden: YES];
    tempView.hidden = YES;
    
    //Show labels for periodicity after guiding image is hidden
    UILabel* periodicity = [[UILabel alloc] initWithFrame:CGRectMake(170, 0, 220, 50)];
    periodicity.tag = 1006;
    periodicity.numberOfLines = 1;
    periodicity.textAlignment = NSTextAlignmentCenter;
    [periodicity setFont:[UIFont fontWithName:@"Comic Sans MS" size:23]];
    periodicity.text = @" Periodicity ";
    periodicity.textColor = [UIColor grayColor];
    [self.view addSubview:periodicity];
    
    //Show labels for periodic motionafter  guiding image is hidden
     UILabel* AboutMotion = [[UILabel alloc] initWithFrame:CGRectMake(280, 50, 550, 130)];
     AboutMotion.tag = 1005;
     AboutMotion.numberOfLines = 3;
     AboutMotion.textAlignment = NSTextAlignmentCenter;
     [AboutMotion setFont:[UIFont fontWithName:@"Comic Sans MS" size:25]];
     AboutMotion.text = @" The back and forth motion of swing pendulum repeats in equal amount of time. It is called 'Periodic Motion'";
     AboutMotion.textColor = [UIColor whiteColor];
     AboutMotion.backgroundColor = [UIColor grayColor];
     [self.view addSubview:AboutMotion];
    
    UILabel* reset = [[UILabel alloc] initWithFrame:CGRectMake(280, 550, 550, 130)];
    reset.tag = 1006;
    reset.numberOfLines = 3;
    reset.textAlignment = NSTextAlignmentCenter;
    [reset setFont:[UIFont fontWithName:@"Comic Sans MS" size:25]];
    reset.text = @" You can tap on the screen to reset. Redraw the rectangle to select your friend";
    reset.textColor = [UIColor whiteColor];
    //reset.backgroundColor = [UIColor grayColor];
    [self.view addSubview:reset];
    
}

- (void)processImage:(cv::Mat &)image
{
    if (rectLeftTopPoint.x != 0 && rectLeftTopPoint.y != 0 && rectRightDownPoint.x != 0 && rectRightDownPoint.y != 0 && !beginInit && !startTracking) {
        
        rectangle(image, cv::Point(rectLeftTopPoint.x * RATIO,rectLeftTopPoint.y * RATIO), cv::Point(rectRightDownPoint.x * RATIO,rectRightDownPoint.y * RATIO), Scalar(0,0,255));
    }
    
    switch (trackType) {
        case CMT_TRACKER:
            [self cmtTracking:image];
            break;
        default:
            break;
    }
    
    
}



- (void)cmtTracking:(cv::Mat &)image
{
    Mat img_gray;
    cvtColor(image,img_gray,CV_RGB2GRAY);
    
    if (beginInit) {
        if (cmtTracker != NULL) {
            delete cmtTracker;
        }
        cmtTracker = new cmt::CMT();
        cmtTracker->initialize(img_gray,initCTBox);
        NSLog(@"cmt track init!");
        startTracking = true;
        beginInit = false;
    }
    
    if (startTracking)
    {
        //NSLog(@"cmt process...");
        cmtTracker->processFrame(img_gray);
        
        
        
        /*//Draws circles at all keypints being tracked
         for(size_t i = 0; i < cmtTracker->points_active.size(); i++)
         {
         // circle(image, cmtTracker->points_active[i], 2, Scalar(rand()%255,rand()%255,rand()%255));
         }
         */
        
        RotatedRect rect = cmtTracker->bb_rot;
        
        Point2f vertices_new[4];
        rect.points(vertices_new);
        
        
        float width = 640;
        float height = 640;
        Point2f pivot_top, pivot_bottom,right_center,left_center;
        pivot_top.x = width/2;
        pivot_top.y = 0;
        pivot_bottom.x = pivot_top.x;
        pivot_bottom.y = height;
        right_center.x = width;
        right_center.y = height/1.8;
        left_center.x = 0;
        left_center.y = right_center.y;
        
        
        //Mat created for blending with mat image so that pendulum shape can be filled with transparancy
        cv::Mat copy;
        copy = image.clone();
        
        //Drawing the pivot and line joining the pivot and center of the pendulum
        circle(image, pivot_top, 3, Scalar(255,255,0), -1);
        line(image,pivot_top,rect.center, Scalar(255,255,0),0.5,LINE_8);
        
        //lines to guide the position of the player on swing
        line(copy, pivot_top,pivot_bottom, Scalar(0,255,255));
        line(copy, right_center,left_center, Scalar(0,255,255));
        
        // Periodic motion, in physics, motion repeated in equal intervals of time.
        
        for (int i = 0; i < 4; i++)
        {
            //line(image, vertices_new[i], vertices_new[(i+1)%4], Scalar(255,0,255),0.1,LINE_8);
            // circle(image, rect.center, 10, Scalar(0,255,0), 1, 8);
            ellipse(copy, rect, Scalar(255,255,0),-1);
        }
      
        /*//code for counting cycles based on how many times pendulum crosses the midpoint of axis drawn
        float count;
        if ( rect.center.x == pivot_top.x)
        {
            count++;
            NSLog(@"Period Count is:");
        }
        */
        
        Point2f newCenter ; // point to create a remapped pendulum, this is to visualise periodicity on x axis or amplitude of the motion
        newCenter.x =  rect.center.x;
        newCenter.y = 20;
        circle(copy, newCenter, 10, Scalar(255,255,0), -1);
        line(copy, Point2f(0,20),Point2f(640,20), Scalar(0,255,255));
        
        
        
        //blending the two mats
        addWeighted(copy, 0.3, image, 0.9, 0.0, image);
        
    }
}


@end