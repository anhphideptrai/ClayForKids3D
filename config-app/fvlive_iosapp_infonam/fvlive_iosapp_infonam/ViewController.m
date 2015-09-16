//
//  ViewController.m
//  fvlive_iosapp_infonam
//
//  Created by Phi Nguyen on 9/15/15.
//  Copyright (c) 2015 INFONAM INC. All rights reserved.
//

#import "ViewController.h"
#import "VideoFrameExtractor.h"
#import "Constants.h"
#import "WebService.h"
#import "DownloadManager.h"
#import "Utilities.h"

@interface ViewController ()<DownloadManagerDelegate>{
    float lastFrameTime;
    NSTimer *timerUpdateFrameVideo;
    VideoEntry *vEntry;
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (nonatomic, retain) VideoFrameExtractor *video;
-(IBAction)playButtonAction:(id)sender;
- (IBAction)stopButtonAction:(id)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setUserInteractionEnabled:NO];
    [_loadingView startAnimating];
    [_playButton setEnabled:NO];
    [_stopButton setEnabled:NO];
    
    NSString *urlAPI = [NSString stringWithFormat:@"http://fvlivedemo.gnzo.com/fvLIVEApp0315/api/getFvInfo.php?id=%d", arc4random_uniform(4) + 1];
    // Query API and Download video
    [[WebService getInstance] getAPIFrom:urlAPI andFinished:^(VideoEntry *videoEntry, BOOL success) {
        if (success) {
            vEntry = videoEntry;
            if ([[[vEntry.video_url componentsSeparatedByString:@"."] lastObject] isEqualToString:@"mp4"]) {
                [[DownloadManager getInstance] setDelegate:self];
                [[DownloadManager getInstance] downloadFileWithUrl:vEntry.video_url];
            }else{
                [self initVideoFrameExtractorWith:vEntry.video_url];
                [self playButtonAction:_playButton];
                [self.view setUserInteractionEnabled:YES];
                [_loadingView stopAnimating];
            }
        }
    }];
}

- (void)initVideoFrameExtractorWith:(NSString*)urlVideo{
    self.video = [[VideoFrameExtractor alloc] initWithVideo:urlVideo];
    /* Output image size. Set to the source size by default.
    _video.outputWidth = 240;
    _video.outputHeight = 135;
     */
}

-(IBAction)playButtonAction:(id)sender {
    if (timerUpdateFrameVideo) {
        [timerUpdateFrameVideo invalidate];
        timerUpdateFrameVideo = nil;
    }
    [_playButton setEnabled:NO];
    lastFrameTime = -1;
    // seek to 0.0 seconds
    [_video seekTime:0.0];
    timerUpdateFrameVideo = [NSTimer scheduledTimerWithTimeInterval:1.0/30
                                     target:self
                                   selector:@selector(displayNextFrame:)
                                   userInfo:nil
                                    repeats:YES];
}

- (IBAction)stopButtonAction:(id)sender {
    if (timerUpdateFrameVideo) {
        [timerUpdateFrameVideo invalidate];
        timerUpdateFrameVideo = nil;
    }
    _imageView.image = nil;
    [_label setText:@"fps"];
    [_playButton setEnabled:YES];
    [_stopButton setEnabled:NO];
}

- (IBAction)showTime:(id)sender {
    NSLog(@"current time: %f s",_video.currentTime);
}

-(void)displayNextFrame:(NSTimer *)timer {
    NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
    [_stopButton setEnabled:YES];
    if (![_video stepFrame]) {
        [timer invalidate];
        [_playButton setEnabled:YES];
        [_stopButton setEnabled:NO];
        return;
    }
    _imageView.image = _video.currentImage;
    
    float frameTime = 1.0/([NSDate timeIntervalSinceReferenceDate]-startTime);
    if (lastFrameTime<0) {
        lastFrameTime = frameTime;
    } else {
        lastFrameTime = LERP(frameTime, lastFrameTime, 0.8);
    }
    NSLog(@"startTime=%f lastFrameTime=%f", startTime, lastFrameTime);
    [_label setText:[NSString stringWithFormat:@"%.0f",lastFrameTime]];
}
#pragma mark - DownloadManagerDelegate methods
- (void)didFinishedDownloadFileWith:(NSURL*)filePath{
    [self initVideoFrameExtractorWith:[Utilities documentsPath:[[vEntry.video_url componentsSeparatedByString:@"/"] lastObject]]];
    [self playButtonAction:_playButton];
    [self.view setUserInteractionEnabled:YES];
    [_loadingView stopAnimating];
}
- (void)completePercent:(NSInteger)percent{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_label setText:[NSString stringWithFormat:@"[%ld%%]", (long)percent]];
    });
}
@end
