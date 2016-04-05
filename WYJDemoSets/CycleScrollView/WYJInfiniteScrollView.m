//
//  WYJInfiniteScrollView.m
//
//
//  Created by wuyj on 16/2/17.
//  Copyright © 2016年 wuyj. All rights reserved.
//

#import "WYJInfiniteScrollView.h"

@interface WYJInfiniteScrollView()

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) NSInteger currentPageIndex;
@property (nonatomic, strong) NSMutableArray *visibleItems;
@property (nonatomic, strong) NSMutableArray *reusableQueue;
@property (nonatomic, strong) UIView *containerView;
@end

@implementation WYJInfiniteScrollView

- (void)initialization {
    
    self.visibleItems = [[NSMutableArray alloc] init];
    self.reusableQueue = [[NSMutableArray alloc] init];
    
    self.circular = NO;
    self.currentIndex = 0;
    self.delegate = self;
    
    self.containerView = [[UIView alloc] init];
    [self addSubview:self.containerView];
    
    [self setShowsVerticalScrollIndicator:NO];
    [self setShowsHorizontalScrollIndicator:NO];
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

- (void)awakeFromNib {
    
	[self calculateContentSize];
}

- (id)dequeueReusableItem {
    id item = [self.reusableQueue lastObject];
    [self.reusableQueue removeObject:item];
    return item;
}

- (void)calculateContentSize {
    
	if (!self.dataSource) return;
	
	NSUInteger totalItems = [self.dataSource numberOfItemsInInfiniteScrollView:self];
    
    if (totalItems  <= 0) {
        return;
    }
    
	CGSize totalGridSize = CGSizeMake(0.0, self.bounds.size.height);
	for (int i = 0; i < totalItems; i++) {
		totalGridSize.width += [self.dataSource infiniteScrollView:self widthForIndex:i];
	}
	
	self.contentSize = CGSizeMake(totalGridSize.width, totalGridSize.height);
	self.containerView.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // If not dragging, send event to next responder
    
    NSUInteger totalItems = [self.dataSource numberOfItemsInInfiniteScrollView:self];
    if (totalItems  <= 0) {
        return;
    }

    
    if (!self.dragging) {
        UITouch *touch = [touches anyObject];
        CGPoint newPoint = [touch locationInView:self];
        UIView *result = [self itemViewAtPoint:newPoint];
        if (_infiniteDelegate && [_infiniteDelegate respondsToSelector:@selector(infiniteScrollView:didSelectedAtIndex:)]) {
            [_infiniteDelegate infiniteScrollView:self didSelectedAtIndex:result.tag];
        }
        [self.nextResponder touchesEnded: touches withEvent:event]; 
    } else {
        [super touchesEnded: touches withEvent: event];
    }
}

- (void)jumpToIndex:(NSInteger)index {
    
    NSUInteger totalItems = [self.dataSource numberOfItemsInInfiniteScrollView:self];
    
    if (totalItems  <= 0) {
        return;
    }

    
    if ((self.isCircular && index < 0) &&
		(self.isCircular && index >= [self.dataSource numberOfItemsInInfiniteScrollView:self]))
		return;
	
	[self setContentOffset:CGPointMake(0, self.contentOffset.y) animated:NO];
	
	CGRect visibleBounds = [self convertRect:self.bounds toView:self.containerView];
	CGFloat minimumVisibleX = CGRectGetMinX(visibleBounds);
	CGFloat maximumVisibleX = CGRectGetMaxX(visibleBounds);
	
	[self.visibleItems removeAllObjects];
	self.currentIndex = index;
	
	[self tileItemsFromMinX:minimumVisibleX toMaxX:maximumVisibleX];
    
    if ([_infiniteDelegate respondsToSelector:@selector(infiniteScrollView:didScrollToIndex:)]) {
        [_infiniteDelegate infiniteScrollView:self didScrollToIndex:index];
    }
}

- (UIView *)getViewFromVisibleCellsWithIndex:(NSInteger)index {
	__block UIView *view = nil;
	[self.visibleItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		UIView *visibleView = (UIView *)obj;
		
		if (visibleView.tag == index) {
			view = visibleView;
			*stop = YES;
		}
	}];
	
	return view;
}

- (void)setDataSource:(id<WYJInfiniteScrollViewDataSource>)dataSource {
	_dataSource = dataSource;
	[self calculateContentSize];
}

- (void)reloadData {
	if (!self.dataSource) return;
	
	[self calculateContentSize];
	[self jumpToIndex:0];
}

#pragma mark - Layout

// recenter content periodically
- (void)recenterIfNecessary {
    CGPoint currentOffset = self.contentOffset;
    CGFloat contentWidth = self.contentSize.width;
    CGFloat centerOffsetX = (contentWidth - self.bounds.size.width) / 2.0;
    CGFloat distanceFromCenter = fabs(currentOffset.x - centerOffsetX);
    
    if (distanceFromCenter > (contentWidth / 4.0)) {
        self.contentOffset = CGPointMake(centerOffsetX, currentOffset.y);
        
        for (UIView *item in self.visibleItems) {
            CGPoint center = [self.containerView convertPoint:item.center toView:self];
            center.x += (centerOffsetX - currentOffset.x);
            item.center = [self convertPoint:center toView:self.containerView];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSUInteger totalItems = [self.dataSource numberOfItemsInInfiniteScrollView:self];
    
    if (totalItems  <= 0) {
        return;
    }

    
    [self recenterIfNecessary];
    
    // tile content in visible bounds
    CGRect visibleBounds = [self convertRect:self.bounds toView:self.containerView];
    CGFloat minimumVisibleX = CGRectGetMinX(visibleBounds);
    CGFloat maximumVisibleX = CGRectGetMaxX(visibleBounds);
    
    [self tileItemsFromMinX:minimumVisibleX toMaxX:maximumVisibleX];
}

#pragma mark - Tiling
- (UIView *)insertItemWithIndex:(NSInteger)index {
    
    if (_dataSource && [_dataSource respondsToSelector:@selector(infiniteScrollView:forIndex:)]) {
        UIView *viewFromDelegate = [self.dataSource infiniteScrollView:self forIndex:index];
        viewFromDelegate.tag = index;
        [self.containerView addSubview:viewFromDelegate];
        
        return viewFromDelegate;
    }
    
    return nil;
}

- (CGFloat)placeNewItemOnRight:(CGFloat)rightEdge {
    
    if ([self.visibleItems count] > 0) {
        UIView *lastItem = [self.visibleItems lastObject];
        NSInteger nextIndex = lastItem.tag + 1;
        if ([self isCircular])
            nextIndex = (nextIndex >= [self.dataSource numberOfItemsInInfiniteScrollView:self]) ? 0 : nextIndex;
        self.currentIndex = nextIndex;
    }
    
    UIView *item = [self insertItemWithIndex:self.currentIndex];
    if (item) {
        [self.visibleItems addObject:item];
    }
    
    
    CGRect frame = item.frame;
    frame.origin.x = rightEdge;
    frame.origin.y = 0;
    item.frame = frame;
    
    return CGRectGetMaxX(frame);
}

- (CGFloat)placeNewItemOnLeft:(CGFloat)leftEdge {
    
    UIView *firstItem = [self.visibleItems objectAtIndex:0];
    NSInteger previousIndex = firstItem.tag - 1;
    if ([self isCircular])
        previousIndex = (previousIndex < 0) ? [self.dataSource numberOfItemsInInfiniteScrollView:self]-1 : previousIndex;
    self.currentIndex = previousIndex;
    
    UIView *item = [self insertItemWithIndex:self.currentIndex];
    [self.visibleItems insertObject:item atIndex:0];
    
    CGRect frame = item.frame;
    frame.origin.x = leftEdge - frame.size.width;
    frame.origin.y = 0;
    item.frame = frame;
    
    return CGRectGetMinX(frame);
}

- (void)tileItemsFromMinX:(CGFloat)minimumVisibleX toMaxX:(CGFloat)maximumVisibleX {
    if ([self.visibleItems count] == 0) {
        [self placeNewItemOnRight:minimumVisibleX];
    }
    
    UIView *lastItem = [self.visibleItems lastObject];
    CGFloat rightEdge = CGRectGetMaxX(lastItem.frame);
    while (rightEdge < maximumVisibleX) {
        rightEdge = [self placeNewItemOnRight:rightEdge];
    }
    
    UIView *firstItem = [self.visibleItems objectAtIndex:0];
    CGFloat leftEdge = CGRectGetMinX(firstItem.frame);
    while (leftEdge > minimumVisibleX) {
        leftEdge = [self placeNewItemOnLeft:leftEdge];
    }
    
    lastItem = [self.visibleItems lastObject];
    while (lastItem.frame.origin.x > maximumVisibleX) {
        [lastItem removeFromSuperview];
        [self.visibleItems removeLastObject];
        [self.reusableQueue addObject:lastItem];
        
        lastItem = [self.visibleItems lastObject];
    }
    
    firstItem = [self.visibleItems objectAtIndex:0];
    while (CGRectGetMaxX(firstItem.frame) < minimumVisibleX) {
        [firstItem removeFromSuperview];
        [self.visibleItems removeObjectAtIndex:0];
        [self.reusableQueue addObject:firstItem];
        
        firstItem = [self.visibleItems objectAtIndex:0];
    }
}

- (UIView *)itemViewAtPoint:(CGPoint)point {
    __block UIView *view = nil;
    [self.visibleItems enumerateObjectsUsingBlock:^(UIView *visibleView, NSUInteger idx, BOOL *stop) {
        if (CGRectContainsPoint(visibleView.frame, point)) {
            view = visibleView;
            *stop = YES;
        }
    }];
    
    return view;
}

#pragma mark - Scroll View Delegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([_infiniteDelegate respondsToSelector:@selector(infiniteScrollView:didScrollToIndex:)]) {
        UIView *item = [self itemViewAtPoint:scrollView.contentOffset];
        if (item && item.tag != self.currentPageIndex) {
            self.currentPageIndex = item.tag;
            [_infiniteDelegate infiniteScrollView:self didScrollToIndex:item.tag];
        }
    }
}

// custom paging
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if (self.isPaging) {
        CGPoint velocity = [scrollView.panGestureRecognizer velocityInView:[self superview]];
        
        UIView *item = [self itemViewAtPoint:scrollView.contentOffset];
        
        CGPoint destinationPoint;
        if (velocity.x > 0) {
            destinationPoint = [item convertPoint:CGPointMake(0.0, 0.0) toView:scrollView];
        } else {
            destinationPoint = [item convertPoint:CGPointMake(item.bounds.size.width, 0.0) toView:scrollView];
        }
        
        [scrollView setContentOffset:destinationPoint animated:YES];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.isPaging) {
        if (!decelerate) {
            UIView *item = [self itemViewAtPoint:scrollView.contentOffset];
            CGPoint localPoint = [scrollView convertPoint:scrollView.contentOffset toView:item];
            
            CGPoint destinationPoint;
            if (localPoint.x > (item.bounds.size.width / 2)) {
                destinationPoint = [item convertPoint:CGPointMake(item.bounds.size.width, 0.0) toView:scrollView];
            } else {
                destinationPoint = [item convertPoint:CGPointMake(0.0, 0.0) toView:scrollView];
            }
            [UIView animateWithDuration:.15 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{scrollView.contentOffset = destinationPoint;} completion:nil];
        }
    }
}

@end
