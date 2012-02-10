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
@property (nonatomic, strong) NSUserDefaults* userDefaults;
@end

@implementation GraphViewController

@synthesize graphView = _graphView;
@synthesize program = _program;
@synthesize variablesStore = _variablesStore;
@synthesize userDefaults = _userDefaults;

-(void) setProgram:(id)program
{
    if (program == _program) return;
    _program = program;
    [self.view setNeedsDisplay];
}

-(void) setGraphView:(GraphView *)graphView
{
    _graphView = graphView;
    [graphView setDatasource:self];  
    // we could have registered gesture recognizers here but it makes more sense to do so
    // in the setup of the GraphView because gestures change the view not the model
    
    // load user defaults
    graphView.origin = CGPointMake([self.userDefaults doubleForKey:@"origin.x"], 
                                   [self.userDefaults doubleForKey:@"origin.y"]);
    graphView.scale = [self.userDefaults doubleForKey:@"scale"];
}

-(void) setVariablesStore:(NSDictionary *)variablesStore
{
    _variablesStore = variablesStore;
    [self.view setNeedsDisplay];
}

-(NSUserDefaults*) userDefaults
{
    if (!_userDefaults) {
        // first time to access userDefaults
        _userDefaults = [NSUserDefaults standardUserDefaults];
        // register default values
        NSDictionary* defaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithDouble:self.view.bounds.origin.x + self.view.bounds.size.width / 2], @"origin.x",
                                  [NSNumber numberWithDouble:self.view.bounds.origin.y + self.view.bounds.size.height / 2], @"origin.y",
                                  [NSNumber numberWithDouble:1], @"scale",
                                  nil];
        [_userDefaults registerDefaults:defaults];
    }
    return _userDefaults;
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
    return YES;
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

-(void) saveGraphOrigin:(CGPoint)origin
{
    // save user defaults    
    [self.userDefaults setDouble:origin.x forKey:@"origin.x"];
    [self.userDefaults setDouble:origin.y forKey:@"origin.y"];
    [self.userDefaults synchronize];
}

-(void) saveGraphScale:(CGFloat)scale
{
    // save user defaults    
    [self.userDefaults setDouble:scale forKey:@"scale"];
    [self.userDefaults synchronize];    
}

@end