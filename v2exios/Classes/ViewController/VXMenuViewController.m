//
//  VXMenuViewController.m
//  v2exios
//
//  Created by myoula on 13-12-26.
//  Copyright (c) 2013年 myoula. All rights reserved.
//

#import "VXMenuViewController.h"
#import "SWRevealViewController.h"
#import "MLNavigationController.h"
#import "VXRecentViewController.h"
#import "VXNoteViewController.h"

@interface VXMenuViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation VXMenuViewController
{
    NSArray *menu;
    UITableView *tableView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"菜单";
    
    menu = [[NSArray alloc] initWithObjects:@"主题", @"节点", @"游客", @"收藏夹", @"设置", nil];
    tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    tableView.dataSource = self;
    tableView.delegate = self;
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,1)];
    tableView.tableFooterView = v;
    [self.view addSubview:tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [menu count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    static NSString *cellIdentifier = @"MenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [menu objectAtIndex:row];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    SWRevealViewController *revealController = self.revealViewController;
    MLNavigationController *frontNavigationController = (id)revealController.frontViewController;
    
    if (row == 0)
    {
        if ( ![frontNavigationController.topViewController isKindOfClass:[VXRecentViewController class]] )
        {
            VXRecentViewController *frontViewController = [[VXRecentViewController alloc] init];
            MLNavigationController *navigationController = [[MLNavigationController alloc] initWithRootViewController:frontViewController];
            [revealController setFrontViewController:navigationController animated:YES];
        }
        else
        {
            [revealController revealToggle:self];
        }
    }
    else if (row == 1)
    {
        if ( ![frontNavigationController.topViewController isKindOfClass:[VXNoteViewController class]] )
        {
            VXNoteViewController *frontViewController = [[VXNoteViewController alloc] init];
            MLNavigationController *navigationController = [[MLNavigationController alloc] initWithRootViewController:frontViewController];
            [revealController setFrontViewController:navigationController animated:YES];
        }
        else
        {
            [revealController revealToggle:self];
        }
    }
    else if (row == 2)
    {
        
    }
    else if (row == 3)
    {
        
    }
    else if (row == 4)
    {
        
    }
}
@end
