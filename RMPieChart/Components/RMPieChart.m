//
//  RMPieChart.m
//  RMPieChart
//
//  Created by Mahesh on 2/4/14.
//  Copyright (c) 2014 Mahesh Shanbhag. All rights reserved.
//

#import "RMPieChart.h"
#import "RMPieLayer.h"
#import "RMPieValueObject.h"
#import <QuartzCore/QuartzCore.h>

@interface RMPieChart()

@property (nonatomic, strong)UIView *chartContainerView;
@property (nonatomic, strong)NSMutableArray *pieChartSlices;
@property (nonatomic, strong)NSMutableArray *pieChartSliceValues;
@property (nonatomic, strong)NSMutableArray *pieChartValueObjectList;

@end

@implementation RMPieChart

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.chartBackgroundColor = [UIColor whiteColor];
        self.pieChartSlices = [NSMutableArray array];
        self.pieChartSliceValues = [NSMutableArray array];
        self.pieChartValueObjectList = [NSMutableArray array];
        _radiusPercent = 0.5;
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
    
    // reload the chart
    [self reloadChart];
    
}

#pragma mark Public Methods
- (void)setRadiusPercent:(CGFloat)radiusPercent
{
    if(radiusPercent > 0.5 || radiusPercent <=0)
    {
        _radiusPercent = 0.5;
        return;
    }
    
    _radiusPercent = radiusPercent;
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

- (void)reloadChart
{
    // get the slice count
    NSInteger numberOfSlices = [self pieSliceCount];
    
    // populate the chart values
    [self populateTheChartValues:numberOfSlices];
    
    // calculate the pievalueObjects first
    [self calculateThePieValueObjects];
    
    // now draw the pie chart
    [self renderPieChart];
}

#pragma mark - DataSource Methods
- (NSUInteger)pieSliceCount
{
    if([self.datasource respondsToSelector:@selector(numberOfSlicesInChartView:)])
        return [self.datasource numberOfSlicesInChartView:self];
    
    return 0;
}

- (void)populateTheChartValues:(NSUInteger)numberOfValues
{
    if([self.datasource respondsToSelector:@selector(percentOfTotalValueOfSliceAtIndexpath:chart:)])
    {
        for (int idx = 0; idx < numberOfValues; idx ++) {
            [self.pieChartSliceValues addObject:@([self.datasource percentOfTotalValueOfSliceAtIndexpath:[NSIndexPath indexPathForRow:idx inSection:0] chart:self])];
        }
    }
    else
    {
        // do nothing
    }
}


- (void)renderPieChart
{
    // we have the pie values not just need to draw the layers
    for(NSInteger idx = 0; idx < self.pieChartSliceValues.count; idx++)
    {
        // get the layers and add the animation to these layers
        [self.pieChartSlices addObject:[self pieLayerWithValueObject:self.pieChartValueObjectList[idx] atIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]]];
    }
    
    // animate the pie chart
    [self animatePie];
}

- (void)animatePie
{
    [CATransaction begin];
    
    // we have the pie values not just need to draw the layers
    for(NSInteger idx = 0; idx < self.pieChartSliceValues.count; idx++)
    {
        // get the layers and add the animation to these layers
        RMPieLayer *pieLayer = self.pieChartSlices[idx];
        RMPieValueObject *valueObject = self.pieChartValueObjectList[idx];
        
        [pieLayer addAnimation:[self addAnimationObjectToPieSlice:pieLayer startSourceAngle:-90 startDestiantionAngle:valueObject.sourceEndAngle endStartAngle:-90 endDestinationAngle:valueObject.destinationEndAngle duration:1] forKey:@"path"];
        
        if(idx == 0)
        {
            [self updatePieValueObject:valueObject prevobj:nil];
        }
        else
        {
            RMPieValueObject *prevObj = self.pieChartValueObjectList[idx - 1];
            [self updatePieValueObject:valueObject prevobj:prevObj];
        }
    }
    
    [CATransaction commit];
}

- (RMPieLayer *)pieLayerWithValueObject:(RMPieValueObject *)valueObject atIndexPath:(NSIndexPath *)path
{
    RMPieLayer *pie = [RMPieLayer layer];
    pie.frame =  self.chartContainerView.bounds;
    pie.path = [self pathWithRadiusPercent:_radiusPercent startAngle:degreeToRadian(valueObject.sourceEndAngle) endAngle:degreeToRadian(valueObject.destinationEndAngle)].CGPath;
    pie.strokeColor = [UIColor blackColor].CGColor;
    pie.lineWidth = 1.0f;
    pie.fillColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.7].CGColor;
    [self.chartContainerView.layer addSublayer:pie];
    
    if([self.datasource respondsToSelector:@selector(colorForSliceAtIndexPath:slice:)])
        pie.fillColor = [self.datasource colorForSliceAtIndexPath:path slice:pie].CGColor;
    
    return pie;
}

#pragma mark - Drawing Path methods
- (UIBezierPath *)pathWithRadiusPercent:(CGFloat)radiusPercent startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle
{
    // get the position
    CGPoint center = CGPointMake(CGRectGetWidth(self.chartContainerView.frame)/2, CGRectGetHeight
                                 (self.chartContainerView.frame)/2);
    
    // retutn the bezier path
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:center];
    [path  addArcWithCenter:center radius:(CGRectGetWidth(self.chartContainerView.frame) * radiusPercent) startAngle:startAngle endAngle:endAngle clockwise:YES];
    [path closePath];
    return path;
}

#pragma mark - Key Frame Animation
- (CAKeyframeAnimation *)addAnimationObjectToPieSlice:(RMPieLayer *)slice startSourceAngle:(CGFloat)startSourceAngle startDestiantionAngle:(CGFloat)startDestinationAngle endStartAngle:(CGFloat)endStartAngle endDestinationAngle:(CGFloat)endDestinationAngle duration:(CGFloat)duration
{
    CAKeyframeAnimation *keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    keyFrameAnimation.duration = duration;
    keyFrameAnimation.values = [self animatingPathsForSlice:slice startSourceAngle:startSourceAngle startDestiantionAngle:startDestinationAngle endStartAngle:endStartAngle endDestinationAngle:endDestinationAngle duration:duration];
    keyFrameAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    return keyFrameAnimation;
}

- (NSMutableArray *)animatingPathsForSlice:(RMPieLayer *)slice startSourceAngle:(CGFloat)startSourceAngle startDestiantionAngle:(CGFloat)startDestinationAngle endStartAngle:(CGFloat)endStartAngle endDestinationAngle:(CGFloat)endDestinationAngle duration:(CGFloat)duration
{
    CGFloat numberForFrames = 60 * duration;
    NSMutableArray *paths = [NSMutableArray arrayWithCapacity:numberForFrames];
    
    for (NSInteger idx = 0; idx < numberForFrames; idx++) {
        CGFloat source = degreeToRadian(startSourceAngle + ((startDestinationAngle - startSourceAngle) * idx)/numberForFrames);
        CGFloat destination = degreeToRadian(endStartAngle + ((endDestinationAngle - endStartAngle) * idx)/numberForFrames);
        [paths addObject:(id)[[self pathWithRadiusPercent:_radiusPercent startAngle:source endAngle:destination] CGPath]];
    }
    
    return paths;
}

#pragma mark - Math Helper Methods
- (void)calculateThePieValueObjects
{
    for (NSInteger idx = 0; idx < self.pieChartSliceValues.count; idx++)
    {
        if(idx > 0)
        {
            RMPieValueObject *prevObj = self.pieChartValueObjectList[idx-1];
            
            RMPieValueObject *obj = [[RMPieValueObject alloc]init];
            obj.sourceStartAngle = -90;
            obj.sourceEndAngle = prevObj.destinationEndAngle;
            obj.destinationStartAngle = prevObj.destinationEndAngle;
            obj.destinationEndAngle = prevObj.destinationEndAngle + [self.pieChartSliceValues[idx] floatValue];
            [self.pieChartValueObjectList addObject:obj];
        }
        else
        {
            RMPieValueObject *obj = [[RMPieValueObject alloc]init];
            obj.sourceStartAngle = -90;
            obj.sourceEndAngle = -90;
            obj.destinationStartAngle = -90;
            obj.destinationEndAngle = [self.pieChartSliceValues[idx] floatValue] - 90;
            [self.pieChartValueObjectList addObject:obj];
        }
    }
}

- (void)updatePieValueObjects
{
    for (NSInteger idx = 0; idx < self.pieChartSliceValues.count; idx++)
    {
        if(idx>self.pieChartValueObjectList.count)
        {
            RMPieValueObject *prevObj = self.pieChartValueObjectList[idx-1];
            RMPieValueObject *obj = [[RMPieValueObject alloc]init];
            
            obj.sourceStartAngle = prevObj.destinationStartAngle;
            obj.sourceEndAngle = prevObj.destinationEndAngle;
            obj.destinationStartAngle = prevObj.destinationEndAngle;
            obj.destinationEndAngle = prevObj.destinationEndAngle + [self.pieChartSliceValues[idx] floatValue];
            [self.pieChartValueObjectList addObject:obj];
        }
        else
        {
            if(idx > 0)
            {
                RMPieValueObject *prevObj = self.pieChartValueObjectList[idx-1];
                
                RMPieValueObject *obj = [[RMPieValueObject alloc]init];
                obj.sourceStartAngle = -90;
                obj.sourceEndAngle = prevObj.destinationEndAngle;
                obj.destinationStartAngle = prevObj.destinationEndAngle;
                obj.destinationEndAngle = prevObj.destinationEndAngle + [self.pieChartSliceValues[idx] floatValue];
                [self.pieChartValueObjectList addObject:obj];
            }
            else
            {
                RMPieValueObject *obj = [[RMPieValueObject alloc]init];
                obj.sourceStartAngle = -90;
                obj.sourceEndAngle = -90;
                obj.destinationStartAngle = -90;
                obj.destinationEndAngle = [self.pieChartSliceValues[idx] floatValue] - 90;
                [self.pieChartValueObjectList addObject:obj];
            }
        }
    }
}

- (void)updatePieValueObject:(RMPieValueObject *)valueObject prevobj:(RMPieValueObject *)prevValueObject
{
    if(prevValueObject)
    {
        valueObject.sourceStartAngle = prevValueObject.destinationEndAngle;
        valueObject.sourceEndAngle = prevValueObject.destinationEndAngle;
        valueObject.destinationStartAngle = valueObject.destinationEndAngle;
        valueObject.destinationEndAngle = valueObject.destinationEndAngle;
    }
    else
    {
        valueObject.sourceStartAngle = valueObject.sourceStartAngle;
        valueObject.sourceEndAngle = valueObject.sourceEndAngle;
        valueObject.destinationStartAngle = valueObject.destinationEndAngle;
        valueObject.destinationEndAngle = valueObject.destinationEndAngle;
    }
}


float degreeToRadian(CGFloat degree)
{
    return ((M_PI * degree)/180.0f);
}

@end
