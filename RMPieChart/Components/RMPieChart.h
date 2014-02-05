//
//  RMPieChart.h
//  RMPieChart
//
//  Created by Mahesh on 2/4/14.
//  Copyright (c) 2014 Mahesh Shanbhag. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RMPieChartDataSource <NSObject>

@required
- (NSUInteger)numberOfSlicesInChartView:(id)chartView;
- (CGFloat)percentOfTotalValueOfSliceAtIndexpath:(NSIndexPath *)indexPath chart:(id)chartView;

@end

@interface RMPieChart : UIView

@property(nonatomic, weak)id<RMPieChartDataSource>datasource;
@property(nonatomic, strong)UIColor *chartBackgroundColor;
@property(nonatomic, assign)CGFloat radiusPercent;

// loads the chart. without call to this there will be no chart!
- (void)loadChart;

// reloads the chart and calls the data source
- (void)reloadChart;

@end
