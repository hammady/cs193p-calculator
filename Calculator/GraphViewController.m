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
//@property (nonatomic, strong) NSMutableDictionary* yCache;
@end

@implementation GraphViewController
@synthesize toolbar = _toolbar;
@synthesize graphView = _graphView;
@synthesize program = _program;
@synthesize variablesStore = _variablesStore;
@synthesize showMasterBarButtonItem = _showMasterBarButtonItem;

//@synthesize yCache = _yCache;

-(void) setProgram:(id)program
{
    if (program == _program) return;
    _program = program;
    [self.graphView setNeedsDisplay];
//    self.yCache = nil;    // invalidate yCache
}

-(void) setGraphView:(GraphView *)graphView
{
    _graphView = graphView;
    [graphView setDatasource:self];  
    // we could have registered gesture recognizers here but it makes more sense to do so
    // in the setup of the GraphView because gestures change the view not the model
//    self.yCache = nil;    // invalidate yCache
}

-(void) setVariablesStore:(NSDictionary *)variablesStore
{
    if (variablesStore == _variablesStore) return;
    _variablesStore = variablesStore;
    [self.graphView setNeedsDisplay];
//    self.yCache = nil;    // invalidate yCache
}

-(void) setShowMasterBarButtonItem:(UIBarButtonItem *)showMasterBarButtonItem
{
    // we need to insert the barButtonItem if !nil or remove it if nil, start by copying the toolbarItems
    NSMutableArray* newToolbarItems = [self.toolbar.items mutableCopy];
    // if we already had an old button, remove it
    if (_showMasterBarButtonItem) [newToolbarItems removeObject:_showMasterBarButtonItem];
    // if we got a new button !nil then add it, otherwise it will not be added
    if (showMasterBarButtonItem) [newToolbarItems insertObject:showMasterBarButtonItem atIndex:0];
    // set back the toolbarItems to our new array
    self.toolbar.items = newToolbarItems;
    // store this button in the property storage so that we may refer to it later
    _showMasterBarButtonItem = showMasterBarButtonItem;
}

/*-(NSMutableDictionary*) yCache
{
    if (!_yCache) _yCache = [[NSMutableDictionary alloc] initWithCapacity:100000];
    // we have at least 320 horizontal x points so the first plot caches 320 points
    return _yCache;
}*/

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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    // register default values
    NSDictionary* defaults = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithDouble:self.view.bounds.origin.x + self.view.bounds.size.width / 2], @"origin.x",
                              [NSNumber numberWithDouble:self.view.bounds.origin.y + self.view.bounds.size.height / 2], @"origin.y",
                              [NSNumber numberWithDouble:1], @"scale",
                              nil];
    [NSUserDefaults.standardUserDefaults registerDefaults:defaults];
    
    // load user defaults
    self.graphView.origin = CGPointMake([NSUserDefaults.standardUserDefaults doubleForKey:@"origin.x"], 
                                   [NSUserDefaults.standardUserDefaults doubleForKey:@"origin.y"]);
    self.graphView.scale = [NSUserDefaults.standardUserDefaults doubleForKey:@"scale"];

    self.splitViewController.delegate = self;
}

- (void)viewDidUnload
{
    [NSUserDefaults.standardUserDefaults synchronize];

    [self setGraphView:nil];
    [self setToolbar:nil];
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
    // performance optimization: cache y values because time profiling shows that runProgram is a bottleneck
    // it turns out that the saving of computation is replaced by hashtable get/set which are more costly!
    // this approach needs a search tree implementation which is agnostic to table size change
    
    /*static int hits = 0;
    static int misses = 0;*/
    
    NSNumber* xNumber = [NSNumber numberWithDouble:x];
    id result;
    
    /*result = [self.yCache objectForKey:xNumber];
    if (result) {
        // cache hit
        hits++;
    } else {
        // cache miss
        misses++;*/
        [self.variablesStore setValue:xNumber forKey:@"x"];
        result = [CalculatorModel runProgram:self.program usingVariablesStore:self.variablesStore];
        /*[self.yCache setObject:result forKey:xNumber];
    }*/
    
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
    [NSUserDefaults.standardUserDefaults setDouble:origin.x forKey:@"origin.x"];
    [NSUserDefaults.standardUserDefaults setDouble:origin.y forKey:@"origin.y"];
}

-(void) saveGraphScale:(CGFloat)scale
{
    // save user defaults    
    [NSUserDefaults.standardUserDefaults setDouble:scale forKey:@"scale"];
}

// SplitViewControllerDelegate methods

-(BOOL) splitViewController:(UISplitViewController *)svc 
   shouldHideViewController:(UIViewController *)vc 
              inOrientation:(UIInterfaceOrientation)orientation
{
    return orientation == UIInterfaceOrientationPortrait;
}

-(void) splitViewController:(UISplitViewController *)svc 
     willHideViewController:(UIViewController *)aViewController 
          withBarButtonItem:(UIBarButtonItem *)barButtonItem 
       forPopoverController:(UIPopoverController *)pc
{
    UIViewController* masterVC = [self.splitViewController.viewControllers objectAtIndex:0];
    barButtonItem.title = masterVC.title;
    self.showMasterBarButtonItem = barButtonItem;
}

-(void) splitViewController:(UISplitViewController *)svc 
     willShowViewController:(UIViewController *)aViewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.showMasterBarButtonItem = nil;
}
@end