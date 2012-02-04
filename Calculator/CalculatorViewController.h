//
//  CalculatorViewController.h
//  Calculator
//
//  Created by Hossam Hammady on 1/25/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalculatorViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *display;
@property (weak, nonatomic) IBOutlet UILabel *programDescription;
@property (weak, nonatomic) IBOutlet UILabel *variablesDisplay;
@property (weak, nonatomic) IBOutlet UIButton *storeButton;
@property (weak, nonatomic) IBOutlet UIButton *xVariableButton;
@property (weak, nonatomic) IBOutlet UIButton *aVariableButton;
@property (weak, nonatomic) IBOutlet UIButton *bVariableButton;
@property (weak, nonatomic) IBOutlet UILabel *usedVariablesDisplay;

@end
