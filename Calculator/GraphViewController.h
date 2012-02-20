//
//  GraphViewController.h
//  Calculator
//
//  Created by Hossam Hammady on 2/8/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphView.h"
#import "BarButtonItemPresenter.h"

@class GraphViewController;

@protocol GraphViewControllerDelegate <NSObject>

-(void) programChanged:(id)program sender:(GraphViewController*)sender;

@end

@interface GraphViewController : UIViewController <GraphDataSource, UISplitViewControllerDelegate, BarButtonItemPresenter>
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet GraphView *graphView;

// begin models (MODELS SHOULD BE ALWAYS STRONG
@property (nonatomic, strong) id program;
@property (nonatomic, strong) NSMutableDictionary* variablesStore;
// end models
@property (nonatomic, weak) id <GraphViewControllerDelegate> delegate;

@end
