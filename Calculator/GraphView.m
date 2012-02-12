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
@property (nonatomic) BOOL duringGesture;
@end

@implementation GraphView

@synthesize scale = _scale;
@synthesize origin = _origin;
@synthesize datasource = _datasource;

@synthesize duringGesture = _duringGesture;

-(void) setScale:(CGFloat)scale
{
    if (!scale) scale = 1.0;
    //if (scale == _scale) return;
    // commented this check because we need to redraw when a gesture ends which typically ends with scale change of 0
    
    _scale = scale;
    [self setNeedsDisplay];
    [self.datasource saveGraphScale:scale];
}

-(void) setOrigin:(CGPoint)origin
{
    //if (origin.x == _origin.x && origin.y == _origin.y) return;
    // commented this check because we need to redraw when a gesture ends which typically ends with translation of 0
    
    _origin = origin;
    [self setNeedsDisplay];
    [self.datasource saveGraphOrigin:origin];
}

-(void) setDatasource:(id<GraphDataSource>)datasource
{
    if (datasource == _datasource) return;
    
    _datasource = datasource;
    [self setNeedsDisplay];
}

-(void) setup
{
    NSLog(@"In GraphView setup");
    
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
    
#define COARSE_STEP_FACTOR 10
    
    // performance point
    // do not draw all points while during gesture, only when gesture is done
    if (self.duringGesture) step *= COARSE_STEP_FACTOR;
    
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
    if (recognizer.state == UIGestureRecognizerStateChanged)
        self.duringGesture = YES;
    else if (recognizer.state == UIGestureRecognizerStateEnded ||
             recognizer.state == UIGestureRecognizerStateCancelled ||
             recognizer.state == UIGestureRecognizerStateFailed)
        self.duringGesture = NO;

    if (recognizer.state == UIGestureRecognizerStateChanged ||
        recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint t = [recognizer translationInView:self];
        self.origin = CGPointMake(self.origin.x + t.x, self.origin.y + t.y);
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

-(void) gesturePinch:(UIPinchGestureRecognizer*) recognizer
{
    if (recognizer.state == UIGestureRecognizerStateChanged)
        self.duringGesture = YES;
    else if (recognizer.state == UIGestureRecognizerStateEnded ||
             recognizer.state == UIGestureRecognizerStateCancelled ||
             recognizer.state == UIGestureRecognizerStateFailed)
        self.duringGesture = NO;

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
