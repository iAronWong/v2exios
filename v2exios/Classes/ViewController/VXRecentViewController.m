//
//  VXRecentViewController.m
//  v2exios
//
//  Created by myoula on 13-12-26.
//  Copyright (c) 2013年 myoula. All rights reserved.
//

#import "VXRecentViewController.h"
#import "SWRevealViewController.h"
#import "VXRequest.h"
#import "TFHpple.h"
#import "SVProgressHUD.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "VXThreadViewController.h"
#import "VXThreadCell.h"
#import "SDWebImage/UIImageView+WebCache.h"

@interface VXRecentViewController ()<VXRequestDelegate, UITableViewDelegate, UITableViewDataSource>

@end

@implementation VXRecentViewController
{
    UITableView *tableView;
    int segindex;
    int p;
    VXRequest *request;
    NSMutableArray *threads;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    
    UISegmentedControl *segmentedControl=[[UISegmentedControl alloc] initWithFrame:CGRectMake(80.0f, 8.0f, 200.0f, 30.0f)];
    [segmentedControl insertSegmentWithTitle:@"最新帖" atIndex:0 animated:NO];
    [segmentedControl insertSegmentWithTitle:@"最近帖" atIndex:1 animated:NO];
    [segmentedControl insertSegmentWithTitle:@"最热帖" atIndex:2 animated:NO];
    
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    [segmentedControl setSelectedSegmentIndex:0];
    self.navigationItem.titleView = segmentedControl;
    
    SWRevealViewController *revealController = [self revealViewController];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStyleBordered target:revealController action:@selector(revealToggle:)];
    
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    threads = [[NSMutableArray alloc] init];
    
    segindex = 0;
    p = 1;
    request = [[VXRequest alloc] init];
    request.delegate = self;
    
    [tableView addPullToRefreshWithActionHandler:^{
        if (segindex == 0) {
            [self refreshALL];
        }
        else
        {
            p = 1;
            [self refreshNewThread:p];
        }
        
    }];
    
    [tableView addInfiniteScrollingWithActionHandler:^{
        p = p + 1;
        [self refreshNewThread:p];
    }];
    
    if (segindex == 0)
    {
        [self refreshALL];
        tableView.showsPullToRefresh = YES;
        tableView.showsInfiniteScrolling = NO;
    }
    else if (segindex == 1)
    {
        [tableView triggerPullToRefresh];
    } else {
        [self refreshHot];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) refreshNewThread:(int) p
{
    if (p == 1)
    {
        [threads removeAllObjects];
        [tableView reloadData];
    }
    
    NSString *url = [[NSString alloc] initWithFormat:RECENT, p];
    [request createConnection:url];
    [SVProgressHUD showWithStatus:@"正在加载..." maskType:SVProgressHUDMaskTypeClear];
}

-(void) refreshALL
{
    [threads removeAllObjects];
    [tableView reloadData];
    
    [request createConnection:ALL];
    [SVProgressHUD showWithStatus:@"正在加载..." maskType:SVProgressHUDMaskTypeClear];
    
}

-(void) refreshHot
{
    [threads removeAllObjects];
    [tableView reloadData];
    
    [request createConnection:HOT];
    [SVProgressHUD showWithStatus:@"正在加载..." maskType:SVProgressHUDMaskTypeClear];

}

-(void) requestFinished:(NSData *)data withErrot:(NSString *)error
{
    [SVProgressHUD dismiss];
    if (error) {
        [SVProgressHUD showErrorWithStatus:error];
    }
    else
    {
        [tableView.pullToRefreshView stopAnimating];
        [tableView.infiniteScrollingView stopAnimating];
        
        TFHpple *doc = [[TFHpple alloc] initWithHTMLData:data];
        NSArray *elements = [doc searchWithXPathQuery:@"//div[@class='cell item']/table"];
        
        for (TFHppleElement *element in elements) {
            NSArray *celements = [element searchWithXPathQuery:@"//td"];
            TFHppleElement *avatarelement = [[[celements objectAtIndex:0] searchWithXPathQuery:@"//img"] objectAtIndex:0];
            TFHppleElement *threadelement = [celements objectAtIndex:2];
            NSArray *replyelements = [[celements objectAtIndex:3] searchWithXPathQuery:@"//a"];
            
            NSString *avatar = [avatarelement objectForKey:@"src"];
            NSString *subject = [[[threadelement searchWithXPathQuery:@"//span/a"] objectAtIndex:0] text];
            NSString *tid = [[[threadelement searchWithXPathQuery:@"//span/a"] objectAtIndex:0] objectForKey:@"href"];
            NSString *nodename = [[[threadelement searchWithXPathQuery:@"//span/a"] objectAtIndex:1] text];
            TFHppleElement *postelement = [[threadelement searchWithXPathQuery:@"//span"] objectAtIndex:1];
            NSString *posted = [[[[[postelement children] objectAtIndex:3] content] componentsSeparatedByString:@"  • "] objectAtIndex:1];
            
            NSArray *threaduser = [threadelement searchWithXPathQuery:@"//span/strong/a"];
            NSString *author = [[threaduser objectAtIndex:0] text];
            
            NSString *replyer = [[NSString alloc] init];
            replyer = @"";
            
            if ([threaduser count] > 1)
            {
                replyer = [[threaduser objectAtIndex:1] text];
            }
            
            NSString *replys = [[NSString alloc] init];
            replys = @"0";
            
            if ([replyelements count] > 0) {
                replys = [[replyelements objectAtIndex:0] text];
            }
            
            tid = [[[tid stringByReplacingOccurrencesOfString:@"/t/" withString:@""] componentsSeparatedByString:@"#"] objectAtIndex:0];
            
            NSDictionary *thread = [[NSDictionary alloc] initWithObjectsAndKeys:tid, @"tid", avatar, @"avatar", subject, @"subject", nodename, @"nodename", author, @"author", posted, @"posted", replyer, @"replyer", replys, @"replys", nil];
            
            [threads addObject:thread];
        }
        
        [tableView reloadData];
    }
}

-(void)segmentAction:(id)sender
{
    switch ([sender selectedSegmentIndex]) {
            case 0:
            segindex = 0;
            tableView.showsPullToRefresh = YES;
            tableView.showsInfiniteScrolling = NO;
            [self refreshALL];
            break;
            case 1:
            segindex = 1;
            tableView.showsPullToRefresh = YES;
            tableView.showsInfiniteScrolling = YES;
            [tableView triggerPullToRefresh];
            break;
            case 2:
            segindex = 2;
            tableView.showsPullToRefresh = NO;
            tableView.showsInfiniteScrolling = NO;
            [self refreshHot];
            break;
    }
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [threads count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    static NSString *cellIdentifier = @"MenuCell";
    VXThreadCell *cell = (VXThreadCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (nil == cell)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VXThreadCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.author.text = [[threads objectAtIndex:row] objectForKey:@"author"];
    cell.notename.text = [[threads objectAtIndex:row] objectForKey:@"nodename"];
    cell.subject.text = [[threads objectAtIndex:row] objectForKey:@"subject"];
    [cell.subject sizeToFit];
    cell.replys.text = [[threads objectAtIndex:row] objectForKey:@"replys"];
    cell.posted.text = [[threads objectAtIndex:row] objectForKey:@"posted"];
    cell.replyer.text = [[threads objectAtIndex:row] objectForKey:@"replyer"];
    [cell.avatar setImageWithURL:[NSURL URLWithString:[[threads objectAtIndex:row] objectForKey:@"avatar"]] placeholderImage:[UIImage imageNamed:@"avatar"]];
    cell.avatar.clipsToBounds = YES;
    cell.avatar.layer.cornerRadius = 24;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    VXThreadViewController *threadViewController = [[VXThreadViewController alloc] init];
    threadViewController.tid = [[threads objectAtIndex:row] objectForKey:@"tid"];
    threadViewController.title = [[threads objectAtIndex:row] objectForKey:@"subject"];
    
    [self.navigationController pushViewController:threadViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VXThreadCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.subject.frame.size.height > 18) {
        return 75 + cell.subject.frame.size.height - 30;
    }
    
    return 75;
}

@end
