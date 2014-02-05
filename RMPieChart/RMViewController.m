//
//  RMViewController.m
//  RMPieChart
//
//  Created by Mahesh on 2/4/14.
//  Copyright (c) 2014 Mahesh Shanbhag. All rights reserved.
//

#import "RMViewController.h"
#import "RMPieChart.h"

@interface RMViewController ()<RMPieChartDataSource>

@property(nonatomic, strong)RMPieChart *pieChart;
@property(nonatomic, strong)NSArray *array;

@end

@implementation RMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.array = @[@(90), @(45),@(45),@(110),@(70)];
    
    self.pieChart = [[RMPieChart alloc]initWithFrame:self.view.bounds];
    self.pieChart.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.pieChart.backgroundColor = [UIColor clearColor];
    self.pieChart.chartBackgroundColor = [UIColor clearColor];
    self.pieChart.radiusPercent = 0.3;
    self.pieChart.datasource = self;
    [self.view addSubview:self.pieChart];
    
    [self.pieChart loadChart];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Pie Chart Delegate
- (NSUInteger)numberOfSlicesInChartView:(id)chartView
{
    return 5;
}

- (CGFloat)percentOfTotalValueOfSliceAtIndexpath:(NSIndexPath *)indexPath chart:(id)chartView
{
    return [self.array[indexPath.row] floatValue];
}

- (UIColor *)colorForSliceAtIndexPath:(NSIndexPath *)indexPath slice:(id)pieSlice
{
    return [UIColor colorWithHue:([self.array[indexPath.row] floatValue]/360.0f) saturation:1 brightness:1 alpha:1.0f];
}

@end
