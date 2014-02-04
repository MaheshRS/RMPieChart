//
//  RMPieChart.h
//  RMPieChart
//
//  Created by Mahesh on 2/4/14.
//  Copyright (c) 2014 Mahesh Shanbhag. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RMPieChartDataSource <NSObject>

- (NSUInteger)numberOfSlicesInChartView;
- (CGFloat)percentOfTotalValueOfSlice:(CGFloat)perventOfTotalValue atIndexpath:(NSIndexPath *)indexPath;

@end

@interface RMPieChart : UIView

@property(nonatomic, strong)UIColor *chartBackgroundColor;

// loads the chart. without call to this there will be no chart!
- (void)loadChart;

@end
