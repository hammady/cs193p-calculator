//
//  GraphViewController.m
//  Calculator
//
//  Created by Hossam Hammady on 2/8/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import "GraphViewController.h"
#import "CalculatorModel.h"

@interface GraphViewController()

@end

@implementation GraphViewController

@synthesize graphView = _graphView;
@synthesize program = _program;
@synthesize variablesStore = _variablesStore;

-(void) setProgram:(id)program
{
    _program = program;
    [self.view setNeedsDisplay];
}

-(void) setGraphView:(GraphView *)graphView
{
    _graphView = graphView;
    [graphView setDatasource:self];    
}

-(void) setVariablesStore:(NSDictionary *)variablesStore
{
    _variablesStore = variablesStore;
    [self.view setNeedsDisplay];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [self setGraphView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// GraphDataSource protocol methods
-(double) getYForX:(double)x
{
    [self.variablesStore setValue:[NSNumber numberWithDouble:x] forKey:@"x"];
    id result = [CalculatorModel runProgram:self.program usingVariablesStore:self.variablesStore];
    if ([result isKindOfClass:[NSNumber class]])
        return [result doubleValue];
    else
        return 0;
}

-(NSString*) getGraphDescription
{
    return [CalculatorModel getDescriptionOfProgramInfix:self.program];
}

@end
