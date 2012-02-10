//
//  GraphView.h
//  Calculator
//
//  Created by Hossam Hammady on 2/8/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GraphDataSource <NSObject>
-(double) getYForX:(double)x;
-(NSString*) getGraphDescription;
@end

@interface GraphView : UIView
@property (nonatomic, weak) id <GraphDataSource> datasource;
@property (nonatomic) CGFloat scale;
@property (nonatomic) CGPoint origin;
@end
