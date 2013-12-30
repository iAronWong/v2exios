//
//  VXNoteViewController.m
//  v2exios
//
//  Created by myoula on 13-12-28.
//  Copyright (c) 2013年 myoula. All rights reserved.
//

#import "VXNoteViewController.h"
#import "SWRevealViewController.h"
#import "VXNoteListViewController.h"
#import "VXRequest.h"
#import "TFHpple.h"
#import "SVProgressHUD.h"

@interface VXNoteViewController () <VXRequestDelegate, UITableViewDataSource, UITableViewDelegate>

@end

@implementation VXNoteViewController
{
    UITableView *tableView;
    VXRequest *request;
    NSMutableArray *notes;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"节点";
    notes = [[NSMutableArray alloc] init];
    tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    tableView.dataSource = self;
    tableView.delegate = self;
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,1)];
    tableView.tableFooterView = v;
    
    SWRevealViewController *revealController = [self revealViewController];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStyleBordered target:revealController action:@selector(revealToggle:)];
    
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    request = [[VXRequest alloc] init];
    request.delegate = self;
    [self.view addSubview:tableView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [request createConnection:ALL];
    [SVProgressHUD showWithStatus:@"正在加载..." maskType:SVProgressHUDMaskTypeClear];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) requestFinished:(NSData *)data withErrot:(NSString *)error
{
    if (error) {
        [SVProgressHUD showErrorWithStatus:error];
    }
    else
    {
        [SVProgressHUD dismiss];
        TFHpple *doc = [[TFHpple alloc] initWithHTMLData:data];
        NSArray *elements = [doc searchWithXPathQuery:@"//div[@id='Main']//div[@class='box']"];
        TFHppleElement *noteelement = [elements objectAtIndex:1];
        
        NSArray *notelist = [noteelement searchWithXPathQuery:@"//table"];
        
        for (TFHppleElement *noteboxelement in notelist) {
            NSArray *pnotes = [noteboxelement searchWithXPathQuery:@"//td"];
            NSMutableDictionary *note = [[NSMutableDictionary alloc] init];
            //获取父节点
            [note setValue:[[[pnotes objectAtIndex:0] firstChildWithTagName:@"span"] text] forKey:@"name"];
            
            //获取子节点
            NSMutableArray *cnotelist = [[NSMutableArray alloc] init];
            NSArray *cnotes = [[pnotes objectAtIndex:1] searchWithXPathQuery:@"//a"];
            
            for (TFHppleElement *cnoteelement in cnotes) {
                NSMutableDictionary *cnote = [[NSMutableDictionary alloc] init];
                [cnote setValue:[cnoteelement objectForKey:@"href"] forKey:@"link"];
                [cnote setValue:[cnoteelement text] forKey:@"name"];
                [cnotelist addObject:cnote];
            }
            
            [note setObject:cnotelist forKey:@"list"];
            [notes addObject:note];
        }
        
        [tableView reloadData];
        
    }
    
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [notes count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[notes objectAtIndex:section] objectForKey:@"name"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[notes objectAtIndex:section] objectForKey:@"list"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    static NSString *cellIdentifier = @"NoteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [[[[notes objectAtIndex:section] objectForKey:@"list"] objectAtIndex:row] objectForKey:@"name"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSDictionary *note = [[[notes objectAtIndex:section] objectForKey:@"list"] objectAtIndex:row];
    NSString *name = [note objectForKey:@"name"];
    NSString *link = [note objectForKey:@"link"];
    
    VXNoteListViewController *notelistViewController = [[VXNoteListViewController alloc] init];
    notelistViewController.note = name;
    notelistViewController.link = link;
    
    [self.navigationController pushViewController:notelistViewController animated:YES];
}

@end
