//
//  CycleScrollView.m
//  WYJDemoSets
//
//  Created by wuyj on 16/2/18.
//  Copyright © 2016年 wuyj. All rights reserved.
//

#import "CycleScrollView.h"
#import "WYJDispatchTimer.h"

@interface CycleScrollView ()<WYJInfiniteScrollViewDataSource,WYJInfiniteScrollViewDelegate,WYJDispatchTimerDelegate>

@property(nonatomic, strong) WYJInfiniteScrollView  *infiniteScrollView;
@property(nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) WYJDispatchTimer *timer;

@end

@implementation CycleScrollView



- (void)dealloc {
    [self stopScroll];
}

- (void)stopScroll {
    [self.timer releaseDispatchTimer];
    self.timer = nil;
}

- (void)autoScroll {
    
    self.timer = [WYJDispatchTimer createDispatchTimerInterval:_interval delegate:self];
    [self.timer startDispatchTimer];
    
//    CycleScrollView *wself = self;
//    self.timer = [WYJDispatchTimer createDispatchTimerInterval:_interval block:^{
//        CycleScrollView *sself = wself;
//        
//        [sself autoJumpPage];
//    }];
}

- (void)autoJumpPage {
    NSUInteger number = [_dataSource numberOfItemsInInfiniteScrollView:_infiniteScrollView];
    if (_pageControl.currentPage >= number - 1) {
        _pageControl.currentPage = 0;
    } else {
        _pageControl.currentPage ++;
    }
    
    [_infiniteScrollView jumpToIndex:_pageControl.currentPage];
}


- (void)setDataSource:(id<WYJInfiniteScrollViewDataSource>)dataSource {
    _dataSource = dataSource;
    
    [self reloadData];
}

-(void)setInfiniteDelegate:(id<WYJInfiniteScrollViewDelegate>)infiniteDelegate {
    _infiniteDelegate = infiniteDelegate;
}

- (void)initialization {
    
    WYJInfiniteScrollView *scrollView = [[WYJInfiniteScrollView alloc] initWithFrame:self.bounds];
    scrollView.paging = YES;
    scrollView.circular = YES;
    scrollView.dataSource = self;
    scrollView.infiniteDelegate = self;
    self.infiniteScrollView = scrollView;
    [self addSubview:scrollView];

    self.pageControl = [[UIPageControl alloc] init];
    _pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    _pageControl.currentPage = 0;
    [self addSubview:_pageControl];
    
    _interval = 3.0;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialization];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self initialization];
    }
    return self;
}

- (void)reloadData {
    [self.infiniteScrollView reloadData];
}

#pragma mark -  infiniteScrollView delegate
- (UIView *)infiniteScrollView:(WYJInfiniteScrollView *)scrollView forIndex:(NSInteger)index {
    return [_dataSource infiniteScrollView:scrollView forIndex:index];
}

- (NSUInteger)numberOfItemsInInfiniteScrollView:(WYJInfiniteScrollView *)scrollView {
    NSUInteger number = [_dataSource numberOfItemsInInfiniteScrollView:scrollView];
    // 配置pageController
    
    _pageControl.numberOfPages = number;
    _pageControl.frame = CGRectMake((self.frame.size.width - 10*_pageControl.numberOfPages)/2.0, self.frame.size.height - 15, 10*_pageControl.numberOfPages, 10);
    [_pageControl setCurrentPage:scrollView.currentIndex];
    
    return number;
}

- (CGFloat)infiniteScrollView:(WYJInfiniteScrollView *)scrollView widthForIndex:(NSInteger)index {
    return [_dataSource infiniteScrollView:scrollView widthForIndex:index];
}

- (void)infiniteScrollView:(WYJInfiniteScrollView *)scrollView didSelectedAtIndex:(NSInteger)index {
    [_infiniteDelegate infiniteScrollView:scrollView didSelectedAtIndex:index];
}

- (void)infiniteScrollView:(WYJInfiniteScrollView *)scrollView didScrollToIndex:(NSInteger)index {
    [_pageControl setCurrentPage:index];
    [_infiniteDelegate infiniteScrollView:scrollView didScrollToIndex:index];
}

#pragma mark -  WYJTimerDelegate
- (void)timerTask {
    [self autoJumpPage];
}

@end
