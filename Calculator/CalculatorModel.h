//
//  CalculatorModel.h
//  Calculator
//
//  Created by Hossam Hammady on 1/25/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorModel : NSObject

-(void) pushOperand:(double)operand;
-(double) performOperation:(NSString*)operation;
-(void) clear;
-(void) pushVariable:(NSString*)variable;
-(void) pushOperator:(NSString*)operation;
-(void) undoLastAction;

@property (readonly) id program;

+(double) runProgram:(id)program;
+(NSString*) getDescriptionOfProgram:(id)program;
+(NSString*) getDescriptionOfProgramInfix:(id)program;

+(double) runProgram:(id)program usingVariablesStore:(NSDictionary*)variablesStore;
+(NSSet*) variablesUsedInProgram:(id)program;

@end
