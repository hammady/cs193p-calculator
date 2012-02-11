//
//  BarButtonItemPresenter.h
//  Calculator
//
//  Created by Hossam Hammady on 2/11/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol BarButtonItemPresenter <NSObject>
@property (nonatomic, weak) UIBarButtonItem *showMasterBarButtonItem;
@end
