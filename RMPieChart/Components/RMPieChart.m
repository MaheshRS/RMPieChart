//
//  RMPieChart.m
//  RMPieChart
//
//  Created by Mahesh on 2/4/14.
//  Copyright (c) 2014 Mahesh Shanbhag. All rights reserved.
//

#import "RMPieChart.h"

@interface RMPieChart()

@property (nonatomic, strong)UIView *chartContainerView;

@end

@implementation RMPieChart

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.chartBackgroundColor = [UIColor whiteColor];
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Load Chart
- (void)loadChart
{
    // if chart is already loaded remove the chart and add again
    if(self.chartContainerView)
    {
        [self.chartContainerView removeFromSuperview];
        self.chartContainerView = nil;
    }
    
    // load the chart container View
    [self loadContainerView];
}

#pragma mark - Load ContainerView
- (void)loadContainerView
{
    CGFloat leastEdgeSize = MIN(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    
    // load the chart in this container view, since this is perfectly resized and has even faces
    self.chartContainerView = [[UIView alloc]initWithFrame:CGRectMake((CGRectGetWidth(self.frame) - leastEdgeSize)/2, (CGRectGetHeight(self.frame) - leastEdgeSize)/2, leastEdgeSize, leastEdgeSize)];
    self.chartContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.chartContainerView.backgroundColor = _chartBackgroundColor;
    [self addSubview:self.chartContainerView];
}

@end
