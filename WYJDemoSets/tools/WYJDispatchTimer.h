//
//  WYJDispatchTimer.h
//  WYJDemoSets
//
//  Created by wuyj on 16/2/18.
//  Copyright © 2016年 wuyj. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol WYJDispatchTimerDelegate <NSObject>
- (void)timerTask;
@end

typedef void (^timerBlock)(void);

@interface WYJDispatchTimer : NSObject

// 采用代理的方式，可以不用太注意timer的释放问题
+ (WYJDispatchTimer *)createDispatchTimerInterval:(NSUInteger)interval delegate:(id <WYJDispatchTimerDelegate>)delegate;

/* 采用block 的方式，一定要注意block retain self的问题
 
 类似这样使用：
 CycleScrollView *wself = self;
 self.timer = [WYJTimer createTimerInterval:3.0 block:^{
 CycleScrollView *sself = wself;
 
 [sself autoJumpPage];
 }];
 
 */

+ (WYJDispatchTimer *)createDispatchTimerInterval:(NSUInteger)interval block:(timerBlock)timerBlock;

// 启动定时器
- (void)startDispatchTimer;
// 释放定时器
- (void)releaseDispatchTimer;

@end
