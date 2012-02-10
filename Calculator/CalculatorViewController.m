//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Hossam Hammady on 1/25/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorModel.h"
#import "GraphViewController.h"

@interface CalculatorViewController()
@property (nonatomic) BOOL editingNumber;
@property (nonatomic) BOOL typedPoint;
@property (nonatomic, strong) CalculatorModel* model;
@property (nonatomic) BOOL storingVariable;
@property (nonatomic, strong) NSMutableDictionary* variablesStore;

-(void) updateProgramDisplay;
-(void) updateVariablesDisplay;
-(void) updateUsedVariablesDisplay;
-(void) evaluateProgram;
@end

@implementation CalculatorViewController
@synthesize display = _display;
@synthesize programDescription = _programDescription;
@synthesize variablesDisplay = _variablesDisplay;

@synthesize storeButton = _storeButton;
@synthesize xVariableButton = _xVariableButton;
@synthesize aVariableButton = _aVariableButton;
@synthesize bVariableButton = _bVariableButton;
@synthesize usedVariablesDisplay = _usedVariablesDisplay;
@synthesize editingNumber = _editingNumber;
@synthesize typedPoint = _typedPoint;
@synthesize model = _model;
@synthesize storingVariable = _storingVariable;
@synthesize variablesStore = _variablesStore;

-(CalculatorModel*) model
{
    if (_model == nil) _model = [[CalculatorModel alloc] init];
    return _model;
}

-(NSMutableDictionary*) variablesStore
{
    if (!_variablesStore) _variablesStore = [[NSMutableDictionary alloc] init];
    return _variablesStore;
}

-(void) setStoringVariable:(BOOL)storingVariable
{
    _storingVariable = storingVariable;
    /*UIColor *bgColor, *titleColor;
    NSString *title;*/
    
    if (storingVariable)
    {
        /*bgColor = [UIColor colorWithRed:57 green:96 blue:155 alpha:255];
        titleColor = [UIColor whiteColor];
        title = @"storing";*/
        [self.xVariableButton setTitle:@">x" forState:UIControlStateNormal];
        [self.aVariableButton setTitle:@">a" forState:UIControlStateNormal];
        [self.bVariableButton setTitle:@">b" forState:UIControlStateNormal];
    } else {
        [self.xVariableButton setTitle:@"x" forState:UIControlStateNormal];
        [self.aVariableButton setTitle:@"a" forState:UIControlStateNormal];
        [self.bVariableButton setTitle:@"b" forState:UIControlStateNormal];
    }
    /*[self.storeButton setBackgroundColor:bgColor];
    [self.storeButton setTitleColor:titleColor forState:UIControlStateNormal];
    [self.storeButton setTitle:title forState:UIControlStateNormal];*/
}

- (IBAction)digitPressed:(UIButton*)sender {
    NSString* digit = sender.currentTitle;
    
    if (self.editingNumber) {
        if ([digit isEqual:@"."])
        {
            if (self.typedPoint)
                return;
            else
                self.typedPoint = YES;
        }
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else {
        if ([digit isEqual:@"."]) {
            self.display.text = @"0.";
            self.typedPoint = YES;
        } else if ([digit isEqual:@"0"] && [self.display.text isEqualToString:@"0"]) {
            return;
        } else {
            self.display.text = digit;
        }
        self.editingNumber = YES;
    }
    
    [self updateProgramDisplay]; // to remove the = if any
}

- (IBAction)signPressedWhileEditing {
    if (self.editingNumber)
    {
        double val = [self.display.text doubleValue];
        if (val) self.display.text = [[NSString alloc] initWithFormat:@"%g", -val];
    }
}

- (IBAction)clearPressed {
    [self.model clear];
    self.editingNumber = NO;
    self.typedPoint = NO;
    self.display.text = @"0";
    [self updateProgramDisplay];
    [self updateUsedVariablesDisplay];
}

- (IBAction)enterPressed {
    [self.model pushOperand:[self.display.text doubleValue]];
    self.editingNumber = NO;
    self.typedPoint = NO;
    self.display.text = @"0";
    [self updateProgramDisplay];
}

-(void) evaluateProgram
{
    id result = [CalculatorModel runProgram:self.model.program usingVariablesStore:self.variablesStore];
    //self.display.text = [NSString stringWithFormat:@"%g", result];
    NSString* strResult = result;
    if ([result isKindOfClass:[NSNumber class]]) {
        double dblResult = [(NSNumber*) result doubleValue];
        strResult = [NSString stringWithFormat:@"%g", dblResult];
    }
    self.display.text = strResult;
    [self updateProgramDisplay];
    self.programDescription.text = [self.programDescription.text stringByAppendingString:@"="];
}

- (IBAction)operationPressed:(UIButton*)sender {
    if ([sender.currentTitle isEqualToString:@"+/-"])
    {
        if (self.editingNumber || [self.display.text isEqualToString:@"0"])
            return;
    }

    if (self.editingNumber) [self enterPressed];
    //double result = [self.model performOperation:[sender currentTitle]];
    [self.model pushOperator:sender.currentTitle];
    [self evaluateProgram];
}

- (IBAction)backspacePressed {
    if (self.editingNumber) // undo typing last digit/decimal point
    {
        NSUInteger displayLength = self.display.text.length;
        if (displayLength == 1)
        {
            self.editingNumber = NO;
        } else {
            NSString* lastDigit = [self.display.text substringFromIndex:displayLength - 1];
            self.display.text = [self.display.text substringToIndex:displayLength - 1];
            if ([lastDigit isEqualToString:@"."])
                self.typedPoint = NO;
            return;
        }
    } else {    // undo last action on program
        [self.model undoLastAction];
    }
    [self evaluateProgram];
}

- (IBAction)storePressed {
    self.storingVariable = !self.storingVariable;
}

- (IBAction)variablePressed:(id)sender {
    UIButton* button = (UIButton*) sender;
    NSString* key = button.currentTitle;
    if (self.storingVariable)
    {
        // store current display value in variable
        NSNumber* val = [NSNumber numberWithDouble: [self.display.text doubleValue]];
        key = [key substringFromIndex:1]; // remove the >
        [self.variablesStore setValue:val forKey:key];
        self.storingVariable = NO;
        self.editingNumber = NO;
        self.typedPoint = NO;
        self.display.text = @"0";
        [self updateVariablesDisplay]; // to reflect the new variable
        
        // re-evaluate program because variables changed
        [self evaluateProgram];
    } else {
        // load variable into model program
        if (self.editingNumber) [self enterPressed];
        [self.model pushVariable:key];
        
        [self updateProgramDisplay]; // to display the pushed variable
        
        [self updateUsedVariablesDisplay];
    }
}

- (void) updateProgramDisplay
{
    self.programDescription.text = [CalculatorModel getDescriptionOfProgramInfix:self.model.program];
}

- (void) updateVariablesDisplay
{
    NSString* text = @"";
    for (NSString* key in [self.variablesStore allKeys])
    {
        double val = [[self.variablesStore objectForKey:key] doubleValue];
        text = [text stringByAppendingFormat:@"%@=%g ", key, val];  
    }
    self.variablesDisplay.text = text;
}

- (void) updateUsedVariablesDisplay
{
    NSSet* set = [CalculatorModel variablesUsedInProgram:self.model.program];
    NSString* title = @"Used: ";
    for(NSString* var in set)
        title = [title stringByAppendingFormat:@"%@ ", var];
    self.usedVariablesDisplay.text = title;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"graphSegue"]) {
        GraphViewController* vc = segue.destinationViewController;
        vc.program = self.model.program;
        vc.variablesStore = self.variablesStore;
    }
}

- (void)viewDidUnload {
    [self setProgramDescription:nil];
    [self setVariablesDisplay:nil];
    [self setStoreButton:nil];
    [self setDisplay:nil];
    [self setXVariableButton:nil];
    [self setAVariableButton:nil];
    [self setBVariableButton:nil];
    [self setUsedVariablesDisplay:nil];
    [super viewDidUnload];
}
@end
