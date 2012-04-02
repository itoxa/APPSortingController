//
//  SecondViewController.m
//  APPSortingController-Example
//
//  Created by Anton Pavlyuk on 02.04.12.
//  Copyright (c) 2012 iHata. All rights reserved.
//

#import "SecondViewController.h"
#import "APPSortingController.h"

@implementation SecondViewController
{
    NSString *cellName;
}

@synthesize sortController = sortController_;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        cellName = @"cell name";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Second";
    
    NSArray *items = [NSArray arrayWithObjects:@"NAME", @"DATE", @"LAST VISIT", nil];
    self.sortController = [[APPSortingController alloc] initWithActionButton:@"SORT BY" 
                                                                itemsArray:items 
                                                      parentViewController:self 
                                                         completionHandler:^(NSUInteger buttonIndex) {
                                                             cellName = [items objectAtIndex:buttonIndex];
                                                             [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] 
                                                                           withRowAnimation:UITableViewRowAnimationBottom];
                                                         }];
    sortController_.showAllActionButton = YES;
    sortController_.font = [UIFont boldSystemFontOfSize:14.0];
    sortController_.darkMode = NO;
    sortController_.deltaY = 90.0;
    [sortController_ show];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = cellName;
    
    return cell;
}

@end
