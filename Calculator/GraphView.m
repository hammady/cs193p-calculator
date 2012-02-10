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

@end

@implementation GraphView

@synthesize scale = _scale;
@synthesize origin = _origin;
@synthesize datasource = _datasource;

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

-(void) setDatasource:(id<GraphDataSource>)datasource
{
    _datasource = datasource;
    [self setNeedsDisplay];
}

-(void) setup
{
    NSLog(@"In GraphView setup");
    self.scale = 1;
    CGFloat originX = self.bounds.origin.x + self.bounds.size.width / 2;
    CGFloat originY = self.bounds.origin.y + self.bounds.size.height / 2;
    self.origin = CGPointMake(originX, originY);
    //self.origin = CGPointZero;
    // setting content mode so that the view redraws itself when device is rotated
    self.contentMode = UIViewContentModeRedraw;
    
    // registering gesture recognizers
    // setting the target/selector sets the event handler
    // adding the recognizer to the view makes the view recognize the gesture (turning it on)
    UIPanGestureRecognizer *pangr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gesturePan:)];
    [self addGestureRecognizer:pangr];
    UIPinchGestureRecognizer *pinchgr = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(gesturePinch:)];
    [self addGestureRecognizer:pinchgr];
    UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureTap:)];
    tapgr.numberOfTapsRequired = 3;
    tapgr.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tapgr];
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

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSLog(@"Redrawing GraphView. with origin %g,%g and scale %g", self.origin.x, self.origin.y, self.scale);

    // TODO: play with colors
    [AxesDrawer drawAxesInRect:self.bounds originAtPoint:self.origin scale:self.scale];
    
    CGFloat minX = -self.origin.x / self.scale;
    CGFloat maxX = minX + self.bounds.size.width / self.scale;
    
    double x, y;
    CGFloat screenX, screenY;
    CGContextBeginPath(context);
    
    // iterate over pixels not points to make use of the retina display
    CGFloat step = 1.0/(self.contentScaleFactor * self.scale);
    
    NSLog(@"drawing step = %f", step);
    for (x = minX; x <= maxX; x += step) {
        screenX = x * self.scale + self.origin.x;
        y = [self.datasource getYForX:x];
        screenY = -y * self.scale + self.origin.y;
        if (x == minX)
            CGContextMoveToPoint(context, screenX, screenY);
        else
            CGContextAddLineToPoint(context, screenX, screenY);
    }
    CGContextStrokePath(context);
    
#define TEXT_MARGIN_X 10
#define TEXT_MARGIN_Y 10
#define TEXT_SPACING_X 10
#define TEXT_SPACING_Y 3
    
    // draw graph description
    UIFont* font = [UIFont systemFontOfSize:12];
    NSString* desc = [self.datasource getGraphDescription];
    CGSize descSize = [desc sizeWithFont:font];
    CGRect descRect = CGRectMake(self.bounds.size.width - descSize.width - TEXT_MARGIN_X - TEXT_SPACING_X, 
                                 TEXT_MARGIN_Y + TEXT_SPACING_Y, descSize.width, descSize.height);
    CGRect descBoxRect = CGRectMake(descRect.origin.x - TEXT_SPACING_X, descRect.origin.y - TEXT_SPACING_Y,
                                    descRect.size.width + 2 * TEXT_SPACING_X, descRect.size.height + 2 * TEXT_SPACING_Y);
    CGContextStrokeRect(context, descBoxRect);
    [desc drawInRect:descRect withFont:font];
}

// Gesture recognizer handlers

-(void) gesturePan:(UIPanGestureRecognizer*) recognizer
{
    if (recognizer.state == UIGestureRecognizerStateChanged ||
        recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint t = [recognizer translationInView:self];
        self.origin = CGPointMake(self.origin.x + t.x, self.origin.y + t.y);
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

-(void) gesturePinch:(UIPinchGestureRecognizer*) recognizer
{
    if (recognizer.state == UIGestureRecognizerStateChanged ||
        recognizer.state == UIGestureRecognizerStateEnded) {
        self.scale *= recognizer.scale;
        [recognizer setScale:1.0];
    }
}

-(void) gestureTap:(UITapGestureRecognizer*) recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Triple tap recognized");
        self.origin = [recognizer locationInView:self];
    }
}
@end
