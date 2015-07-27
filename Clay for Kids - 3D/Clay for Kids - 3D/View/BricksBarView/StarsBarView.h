//
//  BottomToolBarView.h
//  Orgit
//
//  Created by Phi Nguyen on 10/29/14.
//  Copyright (c) 2014 Orgit. All rights reserved.
//

#import <UIKit/UIKit.h>
@class StarsBarView;
@protocol StarsBarViewDelegate<NSObject>
- (NSUInteger)numberItemsForStarsBarView:(StarsBarView*)starsBarView;
@end
@interface StarsBarView : UIView
@property (nonatomic, assign) IBOutlet id  <StarsBarViewDelegate> delegate;
- (instancetype)initBricksBarWithFrame:(CGRect)frame;
- (void)setImageBackgroud:(UIImage*)imageBG;
- (void)setBackgroundColorForView:(UIColor*)bGColor;
- (void)setBackgroundAlpha:(CGFloat)alpha;
- (void)loadView;
- (void)clearView;
@end
