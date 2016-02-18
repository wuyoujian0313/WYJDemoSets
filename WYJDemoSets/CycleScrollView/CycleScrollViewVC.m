//
//  CycleScrollViewVC.m
//  WYJDemoSets
//
//  Created by wuyj on 16/2/17.
//  Copyright © 2016年 wuyj. All rights reserved.
//

#import "CycleScrollViewVC.h"
#import "CycleScrollView.h"

@interface CycleScrollViewVC ()<WYJInfiniteScrollViewDataSource,WYJInfiniteScrollViewDelegate>

@property(nonatomic, strong) CycleScrollView *infiniteScrollView;

@end

@implementation CycleScrollViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    CycleScrollView *scrollView = [[CycleScrollView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width - 0, 60)];
    scrollView.infiniteDelegate = self;
    scrollView.dataSource = self;
    scrollView.interval = 1.0;
    [scrollView autoScroll];
    self.infiniteScrollView = scrollView;
    [self.view addSubview:scrollView];
}

#pragma mark - Data Source Methods

- (UIView *)infiniteScrollView:(WYJInfiniteScrollView *)scrollView forIndex:(NSInteger)index {
    UIView *item = [scrollView dequeueReusableItem];
    
    CGFloat itemWidth = [self infiniteScrollView:scrollView widthForIndex:index];
    CGRect frame = CGRectMake(0.0, 0.0, itemWidth, scrollView.bounds.size.height);
    
    UILabel *numberLabel;
    if (item == nil) {
        item = [[UIView alloc] initWithFrame:frame];
        
//        numberLabel = [[UILabel alloc] initWithFrame:frame];
//        [numberLabel setBackgroundColor:[UIColor clearColor]];
//        [numberLabel setTextColor:[UIColor whiteColor]];
//        [numberLabel setFont:[UIFont boldSystemFontOfSize:(scrollView.bounds.size.height * .4)]];
//        [numberLabel setTextAlignment:NSTextAlignmentCenter];
//        [numberLabel setTag:100];
//        [item addSubview:numberLabel];
    } else {
        item.frame = frame;
//        numberLabel = (UILabel *)[item viewWithTag:100];
//        numberLabel.frame = frame;
    }
    
    // set properties
    NSInteger mods = index % [self numberOfItemsInInfiniteScrollView:scrollView];
    if (mods < 0) mods += [self numberOfItemsInInfiniteScrollView:scrollView];
    CGFloat red = mods * (1 / (CGFloat)[self numberOfItemsInInfiniteScrollView:scrollView]);
    item.backgroundColor = [UIColor colorWithRed:red green:0.0 blue:0.0 alpha:1.0];
    
    // set text
    [numberLabel setText:[NSString stringWithFormat:@"[%ld]", (long)index]];
    
    return item;
}

- (NSUInteger)numberOfItemsInInfiniteScrollView:(WYJInfiniteScrollView *)scrollView {
    return 3;
}

- (CGFloat)infiniteScrollView:(WYJInfiniteScrollView *)scrollView widthForIndex:(NSInteger)index {
    return scrollView.frame.size.width;
}

- (void)infiniteScrollView:(WYJInfiniteScrollView *)scrollView didSelectedAtIndex:(NSInteger)index {
    NSLog(@"Selected index : %ld", (long)index);
}

- (void)infiniteScrollView:(WYJInfiniteScrollView *)scrollView didScrollToIndex:(NSInteger)index {
    NSLog(@"scroll to page : %ld", (long)index);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
