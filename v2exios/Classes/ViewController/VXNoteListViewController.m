//
//  VXNoteListViewController.m
//  v2exios
//
//  Created by myoula on 13-12-30.
//  Copyright (c) 2013年 myoula. All rights reserved.
//

#import "VXNoteListViewController.h"
#import "VXRequest.h"
#import "TFHpple.h"
#import "SVProgressHUD.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "VXThreadViewController.h"
#import "VXThreadCell.h"
#import "SDWebImage/UIImageView+WebCache.h"

@interface VXNoteListViewController () <VXRequestDelegate, UITableViewDelegate, UITableViewDataSource>

@end

@implementation VXNoteListViewController
{
    UITableView *tableView;
    int p;
    VXRequest *request;
    NSMutableArray *threads;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.note;
    
    tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    
    threads = [[NSMutableArray alloc] init];
    
    p = 1;
    request = [[VXRequest alloc] init];
    request.delegate = self;
    
    [tableView addPullToRefreshWithActionHandler:^{
        p = 1;
        [self refreshNote:p];
    }];
    
    [tableView addInfiniteScrollingWithActionHandler:^{
        p = p + 1;
        [self refreshNote:p];
    }];
    
    [tableView triggerPullToRefresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) refreshNote:(int) p
{
    if (p == 1)
    {
        [threads removeAllObjects];
        [tableView reloadData];
    }
    
    NSString *url = [[NSString alloc] initWithFormat:NOTE, self.link, p];
    [request createConnection:url];
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
        NSArray *elements = [doc searchWithXPathQuery:@"//div[@id='TopicsNode']//table"];
        
        for (TFHppleElement *element in elements) {
            NSArray *celements = [element searchWithXPathQuery:@"//td"];
            TFHppleElement *avatarelement = [[[celements objectAtIndex:0] searchWithXPathQuery:@"//img"] objectAtIndex:0];
            TFHppleElement *threadelement = [celements objectAtIndex:2];
            NSArray *replyelements = [[celements objectAtIndex:3] searchWithXPathQuery:@"//a"];
            
            NSString *avatar = [avatarelement objectForKey:@"src"];
            NSString *subject = [[[threadelement searchWithXPathQuery:@"//span/a"] objectAtIndex:0] text];
            NSString *tid = [[[threadelement searchWithXPathQuery:@"//span/a"] objectAtIndex:0] objectForKey:@"href"];
            NSString *nodename = self.note;
            TFHppleElement *postelement = [[threadelement searchWithXPathQuery:@"//span"] objectAtIndex:1];
            NSString *posted = [[[[[postelement children] objectAtIndex:1] content] componentsSeparatedByString:@"  • "] objectAtIndex:1];
            
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