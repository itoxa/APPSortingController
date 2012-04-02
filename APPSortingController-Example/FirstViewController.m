//
//  FirstViewController.m
//  APPSortingController-Example
//
//  Created by Anton Pavlyuk on 02.04.12.
//  Copyright (c) 2012 iHata. All rights reserved.
//

#import "FirstViewController.h"
#import "SecondViewController.h"

#import "APPSortingController.h"

@implementation FirstViewController
{
    APPSortingController *sortingController;
    NSString *cellName;
}

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
    
    self.navigationItem.title = @"First";

    NSArray *items = [NSArray arrayWithObjects:@"RECENT", @"OFFICIAL", @"NEAREST", nil];
    sortingController = [[APPSortingController alloc] initWithActionButton:@"SORT BY" 
                                                                itemsArray:items 
                                                      parentViewController:self 
                                                         completionHandler:^(NSUInteger buttonIndex) {
                                                             cellName = [items objectAtIndex:buttonIndex];
                                                             [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] 
                                                                           withRowAnimation:UITableViewRowAnimationBottom];
                                                         }];
    sortingController.showAllActionButton = NO;
    sortingController.font = [UIFont boldSystemFontOfSize:16.0];
    sortingController.darkMode = YES;
    sortingController.deltaY = 120.0;
    [sortingController show];
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
    return 50;
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     SecondViewController *detailViewController = [[SecondViewController alloc] initWithStyle:UITableViewStyleGrouped];
     [self.navigationController pushViewController:detailViewController animated:YES];
     
}

@end
