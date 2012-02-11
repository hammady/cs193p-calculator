//
//  RotatableViewController.m
//  Calculator
//
//  Created by Hossam Hammady on 2/11/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import "RotatableViewController.h"
#import "BarButtonItemPresenter.h"

@implementation RotatableViewController


-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    self.splitViewController.delegate = self;
    [super viewDidLoad];
}

-(id <BarButtonItemPresenter>) splitViewDetail
{
    // if iPad then will return the GraphViewController (detail vc), otherwise returns nil
    
    id gvc = [self.splitViewController.viewControllers lastObject];
    if (![gvc conformsToProtocol:@protocol(BarButtonItemPresenter)])
        gvc = nil;
    return (id <BarButtonItemPresenter>) gvc;
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
    [self splitViewDetail].showMasterBarButtonItem = barButtonItem;
}

-(void) splitViewController:(UISplitViewController *)svc 
     willShowViewController:(UIViewController *)aViewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self splitViewDetail].showMasterBarButtonItem = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


@end
