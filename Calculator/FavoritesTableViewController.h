//
//  FavoritesTableViewController.h
//  Calculator
//
//  Created by Hossam Hammady on 2/16/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FavoritesTableViewController;

@protocol FavoritesTableViewControllerDelegate <NSObject>
@optional
-(void) favoriteSelected:(id)program sender:(FavoritesTableViewController*) sender;
-(void) favoriteDeleted:(id)program sender:(FavoritesTableViewController*) sender;
@end

@interface FavoritesTableViewController : UITableViewController

@property (nonatomic, strong) NSArray* programs;
//@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) id <FavoritesTableViewControllerDelegate> delegate;
@end
