//
//  DSRateView.h
//  Magazine_Test
//
//  Created by Dima on 11/26/14.
//  Copyright (c) 2014 Dima Soldatenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DSRateView;

@protocol DSRateViewDelegate
- (void)rateView:(DSRateView *)rateView ratingDidChange:(float)rating;
@end

@interface DSRateView : UIView

@property (strong, nonatomic) UIImage *notSelectedImage;
@property (strong, nonatomic) UIImage *halfSelectedImage;
@property (strong, nonatomic) UIImage *fullSelectedImage;
@property (assign, nonatomic) float rating;
@property (assign) BOOL editable;
@property (strong) NSMutableArray * imageViews;
@property (assign, nonatomic) int maxRating;
@property (assign) int midMargin;
@property (assign) int leftMargin;
@property (assign) CGSize minImageSize;
@property (assign) id <DSRateViewDelegate> delegate;

@end