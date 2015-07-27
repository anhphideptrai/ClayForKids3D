//
//  BottomToolBarView.m
//  Orgit
//
//  Created by Phi Nguyen on 10/29/14.
//  Copyright (c) 2014 Orgit. All rights reserved.
//

#import "StarsBarView.h"
#import "Constants.h"
#import <UIImageView+AFNetworking.h>
#define _HEIGHT_WIDTH_ITEM_ 40
#define _HEIGHT_NUMBER_ITEM_ 14
#define _MAX_ITEMS_ 5
#define _PADDING_IMG_NUMBER_ 4

@interface StarsBarView(){
    UIImageView *bGImageView;
    NSUInteger dataItems;
    NSMutableArray *items;
}
@end
@implementation StarsBarView
- (instancetype)initBricksBarWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initCommon];
    }
    return self;
}
- (void)initCommon{
    bGImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    dataItems = 0;
    items = [[NSMutableArray alloc] init];
    [self addSubview:bGImageView];
    [bGImageView setFrame:SET_X_Y_FRAME(0,0,self.frame)];
}
- (void)setImageBackgroud:(UIImage*)imageBG{
    if (imageBG) {
        [bGImageView setImage:imageBG];
    }
}
- (void)setBackgroundColorForView:(UIColor*)bGColor{
    if (bGColor) {
        [bGImageView setBackgroundColor:bGColor];
    }
}
- (void)setBackgroundAlpha:(CGFloat)alpha{
    [bGImageView setAlpha:alpha];
}
- (void)loadView{
    [self clearView];
    if (self.delegate && [self.delegate respondsToSelector:@selector(numberItemsForStarsBarView:)]) {
        dataItems = [self.delegate numberItemsForStarsBarView:self];
    }
    NSUInteger numberItem = MIN(dataItems, _MAX_ITEMS_);
    for (int i = 0; i < numberItem; i++) {
        CGFloat _width_space_item_ = self.frame.size.width/numberItem;
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((_width_space_item_ - _HEIGHT_WIDTH_ITEM_)/2 + i*_width_space_item_, (self.frame.size.height - _HEIGHT_WIDTH_ITEM_)/2, _HEIGHT_WIDTH_ITEM_, _HEIGHT_WIDTH_ITEM_)];
        [imgView setContentMode:UIViewContentModeScaleAspectFit];
        [imgView setImageWithURL:[[NSBundle mainBundle] URLForResource:@"star_icon" withExtension:@"png"]];
        
        [items addObject:imgView];
        [self addSubview:imgView];
    }
}
- (void)clearView{
    [items makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [items removeAllObjects];
}
@end
