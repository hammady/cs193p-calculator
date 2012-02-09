//
//  GraphView.m
//  Calculator
//
//  Created by Hossam Hammady on 2/8/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"

@interface GraphView()
@property (nonatomic) CGFloat scale;
@property (nonatomic) CGPoint origin;
@end

@implementation GraphView

@synthesize scale = _scale;
@synthesize origin = _origin;

-(void) setScale:(CGFloat)scale
{
    _scale = scale;
    [self setNeedsDisplay];
}

-(void) setOrigin:(CGPoint)origin
{
    _origin = origin;
    [self setNeedsDisplay];
}

-(void) setup
{
    NSLog(@"In GraphView setup");
    self.scale = 1.0;
    CGFloat originX = self.bounds.origin.x + self.bounds.size.width / 2;
    CGFloat originY = self.bounds.origin.y + self.bounds.size.height / 2;
    self.origin = CGPointMake(originX, originY);
}

-(void) awakeFromNib
{
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //CGContextRef* context = UIGraphicsGetCurrentContext();
    NSLog(@"Redrawing GraphView. with origin %g,%g and scale %g", self.origin.x, self.origin.y, self.scale);
    [AxesDrawer drawAxesInRect:self.bounds originAtPoint:self.origin scale:self.scale];
}

@end
