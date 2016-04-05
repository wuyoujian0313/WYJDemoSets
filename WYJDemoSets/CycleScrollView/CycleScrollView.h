//
//  CycleScrollView.h
//  WYJDemoSets
//
//  Created by wuyj on 16/2/18.
//  Copyright © 2016年 wuyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYJInfiniteScrollView.h"

typedef NS_ENUM(NSUInteger, PageControlPosition) {
    PageControlPositionLeft,
    PageControlPositionCenter,
    PageControlPositionRight
};

@interface CycleScrollView : UIView

@property(nonatomic, strong, readonly) WYJInfiniteScrollView  *infiniteScrollView;
@property(nonatomic, strong, readonly) UIPageControl *pageControl;

@property(nonatomic, assign) NSUInteger interval;
@property(nonatomic, assign) PageControlPosition pageControlPos;

@property(nonatomic, weak) id<WYJInfiniteScrollViewDataSource> dataSource;
@property(nonatomic, weak) id<WYJInfiniteScrollViewDelegate> infiniteDelegate;

- (void)reloadData;
- (void)stopScroll;
- (void)autoScroll;

@end
