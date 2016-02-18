//
//  WYJInfiniteScrollView.h
//
//
//  Created by wuyj on 16/2/17.
//  Copyright © 2016年 wuyj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WYJInfiniteScrollView;

@protocol WYJInfiniteScrollViewDataSource <NSObject>

- (UIView *)infiniteScrollView:(WYJInfiniteScrollView *)scrollView forIndex:(NSInteger)index;
- (NSUInteger)numberOfItemsInInfiniteScrollView:(WYJInfiniteScrollView *)scrollView;
- (CGFloat)infiniteScrollView:(WYJInfiniteScrollView *)scrollView widthForIndex:(NSInteger)index;

@end

@protocol WYJInfiniteScrollViewDelegate <NSObject>

@optional
- (void)infiniteScrollView:(WYJInfiniteScrollView *)scrollView didScrollToIndex:(NSInteger)index;
- (void)infiniteScrollView:(WYJInfiniteScrollView *)scrollView didSelectedAtIndex:(NSInteger)index;

@end

@interface WYJInfiniteScrollView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, assign, getter = isCircular) BOOL circular;
@property (nonatomic, assign, getter = isPaging) BOOL paging;
@property (nonatomic, readonly) NSInteger currentIndex;

@property (nonatomic, weak) id<WYJInfiniteScrollViewDataSource> dataSource;
@property (nonatomic, weak) id<WYJInfiniteScrollViewDelegate> infiniteDelegate;


- (id)dequeueReusableItem;
- (void)jumpToIndex:(NSInteger)index;
- (void)reloadData;


@end
