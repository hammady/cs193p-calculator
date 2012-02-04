//
//  CalculatorModel.m
//  Calculator
//
//  Created by Hossam Hammady on 1/25/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import "CalculatorModel.h"

@interface CalculatorModel()
@property (nonatomic, strong) NSMutableArray* programStack;
+(double) popOperandOffStack:(NSMutableArray*)stack;
+(NSString*) popOperandDescriptionOffStack:(NSMutableArray*)stack;

@end

@implementation CalculatorModel

@synthesize programStack = _programStack;

-(NSMutableArray*) programStack
{
    if (_programStack == nil) _programStack = [[NSMutableArray alloc] init]; 
    return _programStack;
}

+(double) popOperandOffStack:(NSMutableArray*)stack
{
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        result = [(NSNumber*) topOfStack doubleValue];
    }
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
        NSString* operation = (NSString*) topOfStack;
        
        if ([operation isEqualToString:@"+"])
            result = [self popOperandOffStack:stack] + [self popOperandOffStack:stack];
        else if ([operation isEqualToString:@"*"])
            result = [self popOperandOffStack:stack] * [self popOperandOffStack:stack];
        else if ([operation isEqualToString:@"-"]) {
            result = -[self popOperandOffStack:stack] + [self popOperandOffStack:stack];
        }
        else if ([operation isEqualToString:@"/"]) {
            double divisor = [self popOperandOffStack:stack];
            if (divisor) result = [self popOperandOffStack:stack] / divisor;
        }
        else if ([operation isEqualToString:@"sin"])
        {
            result = sin([self popOperandOffStack:stack]);
        }
        else if ([operation isEqualToString:@"cos"])
        {
            result = cos([self popOperandOffStack:stack]);
        }
        else if ([operation isEqualToString:@"log"])
        {
            result = log([self popOperandOffStack:stack]);
        }
        else if ([operation isEqualToString:@"sqrt"])
        {
            result = sqrt([self popOperandOffStack:stack]);
        }
        else if ([operation isEqualToString:@"e"])
        {
            result = M_E;
        }
        else if ([operation isEqualToString:@"pi"])
        {
            result = M_PI;
        }
        else if ([operation isEqualToString:@"+/-"])
        {
            result = -[self popOperandOffStack:stack];
        }
        
    }
    
    return result;
}

+(NSString*) popOperandDescriptionOffStack:(NSMutableArray *)stack
{
    NSString* result = @"";
    
    // TODO: HOW TO DO THE FOLLOWING STATIC? OR STORE ELSEWHERE
    NSSet* functionOperations = [[NSSet alloc] initWithObjects:@"sin", @"cos", @"log", @"sqrt", nil];
    NSSet* binaryOperations = [[NSSet alloc] initWithObjects:@"+", @"-", @"*", @"/", nil];
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        NSNumber* number = (NSNumber*) topOfStack;
        result = [NSString stringWithFormat:@"%g", [number doubleValue]];
    }
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
        NSString* operation = (NSString*) topOfStack;
        if ([functionOperations containsObject:operation])
            result = [[NSString alloc] initWithFormat:@"%@(%@)", operation, [self popOperandDescriptionOffStack:stack]];
        else if ([binaryOperations containsObject:operation])
        {
            NSString* operand2 = [self popOperandDescriptionOffStack:stack];
            NSString* operand1 = [self popOperandDescriptionOffStack:stack];
            result = [[NSString alloc] initWithFormat:@"(%@%@%@)", 
                      operand1, operation, operand2];
        }
        else if ([operation isEqualToString:@"+/-"])
            result = [[NSString alloc] initWithFormat:@"-[%@]", [self popOperandDescriptionOffStack:stack]];
        else
            result = operation;
    }
    
    return result;    
}

-(void) pushOperand:(double)operand
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

-(void) pushVariable:(NSString *)variable
{
    [self.programStack addObject:variable];
}

-(id) program
{
    return [self.programStack copy];
}

-(void) clear
{
    [self.programStack removeAllObjects];
}

+(double) runProgram:(id)program
{
    NSMutableArray* stack;
    if ([program isKindOfClass:[NSArray class]])
    {
        stack = [program mutableCopy];
    }
    return [self popOperandOffStack:stack];
}

+(double) runProgram:(id)program usingVariablesStore:(NSDictionary *)variablesStore
{
    NSMutableArray* stack;
    if ([program isKindOfClass:[NSArray class]])
    {
        stack = [program mutableCopy];
        // replace all variables on stack
        for (int i = 0; i < stack.count; i++)
        {
            id item = [stack objectAtIndex:i];
            if ([item isKindOfClass:[NSString class]])
            {
                NSNumber* val = [variablesStore objectForKey:item];
                if (val) [stack replaceObjectAtIndex:i withObject:val];
            }
        }
    }
    return [self popOperandOffStack:stack];
}

+(NSString*) getDescriptionOfProgram:(id)program
{
    NSString* desc = @"";
    
    if ([program isKindOfClass:[NSArray class]])
    {
        for (id item in (NSArray*) program)
        {
            if ([item isKindOfClass:[NSNumber class]])
            {
                desc = [desc stringByAppendingFormat:@"%g ", [(NSNumber*) item doubleValue]];
            }
            else if ([item isKindOfClass:[NSString class]])
            {
                desc = [desc stringByAppendingFormat:@"%@ ", item];
            }
        }
    }
    return desc;
}

+(NSString*) getDescriptionOfProgramInfix:(id)program
{
    NSMutableArray* stack;
    
    if ([program isKindOfClass:[NSArray class]])
    {
        stack = [program mutableCopy];
    }
    
    NSString* desc = @"";
    while (stack.count) {
        if (![desc isEqualToString:@""]) desc = [desc stringByAppendingString:@", "];
        desc = [desc stringByAppendingString:[self popOperandDescriptionOffStack:stack]];
    }
    return desc;
}

-(double) performOperation:(NSString*)operation
{
    [self.programStack addObject:operation];
    return [[self class] runProgram:self.program];
}

-(void) pushOperator:(NSString *)operation
{
    [self.programStack addObject:operation];
}

+(NSSet*) variablesUsedInProgram:(id)program
{
    NSMutableSet* set;
    if ([program isKindOfClass:[NSArray class]])
    {
        NSArray* stack = (NSArray*) program;
        NSSet* operations = [[NSSet alloc] initWithObjects:
            @"+", @"-", @"*", @"/", @"+/-", @"sin", @"cos", @"log", @"sqrt", @"e", @"pi", nil];
        for (id item in stack)
        {
            if ([item isKindOfClass:[NSString class]] && ![operations containsObject:item])
            {
                if (!set) 
                    set = [[NSMutableSet alloc] initWithObjects:item, nil];
                else
                    [set addObject:item];
            }
        }
    }
    return [set copy];
}

@end
