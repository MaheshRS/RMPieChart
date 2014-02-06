//
//  RMViewController.m
//  RMPieChart
//
//  Created by Mahesh on 2/4/14.
//  Copyright (c) 2014 Mahesh Shanbhag. All rights reserved.
//

#import "RMViewController.h"
#import "RMPieChart.h"

@interface RMViewController ()<RMPieChartDataSource, RMPieChartDelegate>

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
    self.pieChart.delegate = self;
    [self.view addSubview:self.pieChart];
    
    [self.pieChart loadChart];
    
    [self loadData];
    
    [self.view bringSubviewToFront:self.resetBtn];
}

- (void)loadData
{
    self.array = @[@(90), @(45),@(45),@(110),@(70)];
    [self.pieChart reloadChart];
    
    typeof(self) __weak weakself = self;
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        weakself.array = @[@(25),@(20),@(90),@(45),@(110),@(20),@(20),@(30)];
        [weakself.pieChart reloadChart];
    });
    
    
    double delayInSeconds1 = 4.0;
    dispatch_time_t popTime1 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds1 * NSEC_PER_SEC));
    dispatch_after(popTime1, dispatch_get_main_queue(), ^(void){
        weakself.array = @[@(90), @(45),@(45),@(50),@(60),@(70)];
        [weakself.pieChart reloadChart];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Pie Chart Datasource
- (NSUInteger)numberOfSlicesInChartView:(id)chartView
{
    return self.array.count;
}

- (CGFloat)percentOfTotalValueOfSliceAtIndexpath:(NSIndexPath *)indexPath chart:(id)chartView
{
    return [self.array[indexPath.row] floatValue];
}

- (UIColor *)colorForSliceAtIndexPath:(NSIndexPath *)indexPath slice:(id)pieSlice
{
    return [UIColor colorWithHue:([self.array[indexPath.row] floatValue]/360.0f) saturation:1 brightness:1 alpha:1.0f];
}

#pragma mark - Pie Chart Delegate
- (void)didClearChartView:(id)chartView
{
    typeof(self) __weak weakself = self;
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
       [weakself loadData];
    });
}


#pragma mark - Reset button
- (IBAction)resetBtnPressed:(id)sender {
    [self.pieChart resetChart];
}


@end
