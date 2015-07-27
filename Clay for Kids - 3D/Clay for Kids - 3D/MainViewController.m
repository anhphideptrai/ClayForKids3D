//
//  ViewController.m
//  Bricks Animated 3D
//
//  Created by Phi Nguyen on 5/27/15.
//  Copyright (c) 2015 Thien Nguyen. All rights reserved.
//

#import "MainViewController.h"
#import "SQLiteManager.h"
#import "PercentageBarUploadingView.h"
#import "MoreAppsViewController.h"
#import "AppDelegate.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <UIImageView+AFNetworking.h>
#import "Utils.h"
#import "GuideViewController.h"

@interface MainViewController () <UITableViewDataSource,UITableViewDelegate, DownloadManagerDelegate, GADInterstitialDelegate>{
    NSMutableArray *groups;
    PercentageBarUploadingView *_percentageBarUploadingV;
    Clay *claySelected;
    BOOL shouldAds;
    AppDelegate *appDelegate;
    NSTimer *delayShowAdsTimer;
    BOOL isNotFirst;
}
@property (weak, nonatomic) IBOutlet UITableView *tbView;
@property(nonatomic, strong) GADInterstitial *interstitial;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = [UIApplication sharedApplication].delegate;
    [self.navigationItem setTitle:@"Clay For Kids - 3D"];
    
    self.navigationController.navigationBar.tintColor = UIColorFromRGB(0xFF4136);
    
    //create a right side button in the navigation bar
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Like!"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(actionLike)];
    [leftButton setTitleTextAttributes:@{
                                         NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:15.f],
                                         NSForegroundColorAttributeName: UIColorFromRGB(0xFF4136)
                                         } forState:UIControlStateNormal];
    
    [self.navigationItem setLeftBarButtonItem:leftButton];
    
    if (![appDelegate.config.moreShow isEqualToString:_more_default_]) {
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"More"
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(actionMore)];
        [rightButton setTitleTextAttributes:@{
                                              NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:15.f],
                                              NSForegroundColorAttributeName: UIColorFromRGB(0xFF4136)
                                              } forState:UIControlStateNormal];
        [self.navigationItem setRightBarButtonItem:rightButton];
    }
    
    groups = [[SQLiteManager getInstance] getAllClayGroup];
    [appDelegate.downloadManager setDelegate:self];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!isNotFirst) {
        isNotFirst = YES;
        return;
    }
    NSUInteger r = arc4random_uniform(15) + 1;
    if (r == 3) {
        if (!([[NSUserDefaults standardUserDefaults] objectForKey:SHOW_RATING_VIEW_TAG])) {
            [self actionLike];
            return;
        }
    }
    if (delayShowAdsTimer) {
        [delayShowAdsTimer invalidate];
        delayShowAdsTimer = nil;
    }
    if (shouldAds && ![appDelegate.config.adsShow isEqualToString:_ads_default_]) {
        shouldAds = NO;
        NSUInteger r = arc4random_uniform(5) + 1;
        if (r == 3) {
            delayShowAdsTimer = [NSTimer scheduledTimerWithTimeInterval:_TIME_TICK_CHANGE_ target:self selector:@selector(delayShowAds) userInfo:nil repeats:NO];
        }
    }
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (delayShowAdsTimer) {
        [delayShowAdsTimer invalidate];
        delayShowAdsTimer = nil;
    }
}
- (void)delayShowAds{
    self.interstitial = [self createAndLoadInterstitial];
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (void)actionLike{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_msg_rating_ message:nil delegate:self cancelButtonTitle:_msg_dismiss_ otherButtonTitles:_msg_rate_it_5_starts_, nil];
    [alert show];
}
- (void)actionMore{
    MoreAppsViewController *moreAppsVC = [MoreAppsViewController new];
    UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:moreAppsVC];
    [self presentViewController:navC animated:YES completion:^{}];
}
- (void)openClayDetail{
    claySelected.steps = [[SQLiteManager getInstance] getClayStepsWithIDClay:claySelected.iDClay];
    GuideViewController *guideVC = [[GuideViewController alloc] initWithNibName:@"GuideViewController" bundle:nil];
    [guideVC setClay:claySelected];
    shouldAds = YES;
    [self.navigationController pushViewController:guideVC animated:YES];
}
- (UIView *) percentageBarUploadingV{
    if( !_percentageBarUploadingV ) {
        _percentageBarUploadingV = [[PercentageBarUploadingView alloc] initWithNibName:@"PercentageBarUploadingView" bundle:nil];
        [_percentageBarUploadingV.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    }
    [_percentageBarUploadingV setTextLoading:@""];
    [_percentageBarUploadingV setPercent:0];
    return _percentageBarUploadingV.view;
}
- (void)downloadImgWithIDClay:(NSString*)iDClay{
    [self.view setUserInteractionEnabled:NO];
    [self.navigationController.navigationBar addSubview:self.percentageBarUploadingV];
    NSMutableArray *files = [[NSMutableArray alloc] init];
    for (ClayStep *step in [[SQLiteManager getInstance] getClayStepsWithIDClay:iDClay]) {
        DownloadEntry *entry = [[DownloadEntry alloc] init];
        entry.strUrl = step.urlImage;
        entry.dir = step.iDClay;
        entry.fileName = [[step.urlImage componentsSeparatedByString:@"/"] lastObject];
        entry.size = step.size;
        [files addObject:entry];
    }
    [appDelegate.downloadManager dowloadFilesWith:files];
}
- (GADInterstitial *)createAndLoadInterstitial {
    GADInterstitial *interstitial = [[GADInterstitial alloc] initWithAdUnitID:INTERSTITIAL_ID_ADMOB_PAGE];
    interstitial.delegate = self;
    GADRequest *request = [GADRequest request];
    // Requests test ads on simulators.
    request.testDevices = [NSArray arrayWithObjects:@"GAD_SIMULATOR_ID",
                           @"1485d1faa4c1010a54b384ca9e9944b7", @"f2b1a55b050ac3483e1c17a21a2073f5",
                           nil];
    [interstitial loadRequest:request];
    return interstitial;
}
#pragma mark - TableViewControll Delegate + DataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return groups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ((ClayGroup*)groups[section]).clays.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return IS_IPAD?100:80;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 24;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *tempView=[[UIView alloc]initWithFrame:CGRectMake(0,0,tableView.frame.size.width,0)];
    tempView.backgroundColor=UIColorFromRGB(0xf8f8f8);
    
    UILabel *tempLabel=[[UILabel alloc]initWithFrame:CGRectMake(7,0,tableView.frame.size.width,24)];
    tempLabel.backgroundColor=[UIColor clearColor];
    tempLabel.textColor = UIColorFromRGB(0xFF4136); //here you can change the text color of header.
    tempLabel.font = [UIFont fontWithName:@"Helvetica" size:18.f];
    tempLabel.text = ((ClayGroup*)groups[section]).name;
    
    [tempView addSubview:tempLabel];
    return tempView;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [cell.imageView cancelImageRequestOperation];
    [cell.imageView setImage:[UIImage imageNamed:@"icon_placeholder.png"]];
    Clay *clay = ((ClayGroup*)groups[indexPath.section]).clays[indexPath.row];
    [cell.textLabel setText:clay.name];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%lu Steps", (unsigned long)clay.numberStep - 1]];
    [cell.imageView setImageWithURL:[[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"%@_icon", clay.iDClay] withExtension:@"png"]];
    cell.accessoryType = clay.isDownloaded?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
    cell.tintColor = UIColorFromRGB(0xFF4136);
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    claySelected = ((ClayGroup*)groups[indexPath.section]).clays[indexPath.row];
    if (claySelected.isDownloaded) {
        [self openClayDetail];
        
    }else{
        [self downloadImgWithIDClay:claySelected.iDClay];
    }
}
- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:(void (^)(void)) ^{
                         cell.imageView.transform=CGAffineTransformMakeScale(1.2, 1.2);
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                             cell.imageView.transform=CGAffineTransformIdentity;
                         } completion:^(BOOL finished) {}];
                     }];
}
#pragma mark - DownloadManagerDelegate methods
- (void)didFinishedDownloadFilesWith:(NSArray *)filePaths withError:(NSError *)error{
    [self.view setUserInteractionEnabled:YES];
    [_percentageBarUploadingV.view removeFromSuperview];
    if (!error) {
        claySelected.isDownloaded = YES;
        [[SQLiteManager getInstance] didDownloadedClay:claySelected.iDClay];
        [_tbView reloadData];
        [self openClayDetail];
    }else{
        [Utils showAlertWithError:error];
    }
}
- (void)completePercent:(NSInteger)percent{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_percentageBarUploadingV setPercent:percent];
    });
}
#pragma mark - GADInterstitialDelegate methods
- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial {
    [self.interstitial presentFromRootViewController:self];
}
#pragma mark - UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != alertView.cancelButtonIndex) {
        [[NSUserDefaults standardUserDefaults] setValue:@(true) forKey:SHOW_RATING_VIEW_TAG];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appDelegate.config.urliTunes]];
    }
}

@end
