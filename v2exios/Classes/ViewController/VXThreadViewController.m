//
//  VXThreadViewController.m
//  v2exios
//
//  Created by myoula on 13-12-26.
//  Copyright (c) 2013年 myoula. All rights reserved.
//

#import "VXThreadViewController.h"
#import "VXRequest.h"
#import "TFHpple.h"
#import "SVProgressHUD.h"
#import "VXPostCell.h"
#import "VXThreadDetailCell.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "RCLabel.h"

@interface VXThreadViewController ()<UITableViewDataSource, UITableViewDelegate, RTLabelDelegate>

@end

@implementation VXThreadViewController
{
    UITableView *tableView;
    int p;
    VXRequest *request;
    NSDictionary *thread;
    NSMutableArray *posts;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    tableView.dataSource = self;
    tableView.delegate = self;
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,1)];
    tableView.tableFooterView = v;
    [self.view addSubview:tableView];
    
    thread = [[NSDictionary alloc] init];
    posts = [[NSMutableArray alloc] init];
    
    p = 1;
    //self.tid = @"94708";
    request = [[VXRequest alloc] init];
    request.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    NSString *url = [[NSString alloc] initWithFormat:THREAD, self.tid, p];
    [request createConnection:url];
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
        TFHpple *doc = [[TFHpple alloc] initWithHTMLData:data];
        NSArray *elements = [doc searchWithXPathQuery:@"//div[@id='Main']//div[@class='box']"];
        TFHppleElement *threadelement = [elements objectAtIndex:0];
        
        if ([[threadelement searchWithXPathQuery:@"//div[@class='header']/a"] count] > 1) {
            [SVProgressHUD dismiss];
            NSString *nodename = [[[threadelement searchWithXPathQuery:@"//div[@class='header']/a"] objectAtIndex:1] text];
            NSString *subject = [[[threadelement searchWithXPathQuery:@"//div[@class='header']/h1"] objectAtIndex:0] text];
            NSString *author = [[[threadelement searchWithXPathQuery:@"//div[@class='header']/small/a"] objectAtIndex:0] text];
            NSString *posthit = [[[[[threadelement searchWithXPathQuery:@"//div[@class='header']/small"] objectAtIndex:0] children] objectAtIndex:2] content];
            NSString *avatar = [[[threadelement searchWithXPathQuery:@"//div[@class='header']//img"] objectAtIndex:0] objectForKey:@"src"];
            
            NSString *content = [NSString stringWithFormat:@"%@", @""];
            content = @"";
            
            NSArray *contentarr = [threadelement searchWithXPathQuery:@"//div[@class='topic_content']"];
            
            for (TFHppleElement *contentelement in contentarr) {
                content = [NSString stringWithFormat:@"%@%@", content, [[[contentelement raw] stringByReplacingOccurrencesOfString:@"<div class=\"topic_content\">" withString:@"<p>"] stringByReplacingOccurrencesOfString:@"</div>" withString:@"</p>"]];
            }
            
            content = [content stringByReplacingOccurrencesOfString:@"<br/>"  withString:@"\n"];
            
            thread = [[NSDictionary alloc] initWithObjectsAndKeys:nodename, @"nodename", subject, @"subject", content, @"content", author, @"author", posthit, @"posthit", avatar, @"avatar", nil];
            
            if ([elements count] > 1)
            {
                TFHppleElement *postboxelement = [elements objectAtIndex:1];
                NSArray *postselement = [postboxelement searchWithXPathQuery:@"//table"];
                NSArray *posttdelement;
                
                for (TFHppleElement *postelement in postselement) {
                    NSMutableDictionary *post = [[NSMutableDictionary alloc] init];
                    posttdelement = [postelement searchWithXPathQuery:@"//td"];
                    
                    [post setObject:[[[posttdelement objectAtIndex:0] firstChildWithTagName:@"img"] objectForKey:@"src"] forKey:@"avatar"];
                    
                    [post setObject:[[[[posttdelement objectAtIndex:2] searchWithXPathQuery:@"//strong/a"] objectAtIndex:0] text] forKey:@"author"];
                    
                    [post setObject:[[[posttdelement objectAtIndex:2] firstChildWithTagName:@"span"] text] forKey:@"posted"];
                    
                    [post setObject:[[[[[[[posttdelement objectAtIndex:2] searchWithXPathQuery:@"//div[@class='reply_content']"] objectAtIndex:0] raw] stringByReplacingOccurrencesOfString:@"<div class=\"reply_content\">" withString:@""] stringByReplacingOccurrencesOfString:@"</div>" withString:@""] stringByReplacingOccurrencesOfString:@"<br/>"  withString:@"\n"] forKey:@"content"];
                    
                    [posts addObject:post];
                }
            }
            
            [tableView reloadData];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"查看本主题需要登录"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [posts count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    static NSString *tcellIdentifier = @"ThreadCell";
    static NSString *pcellIdentifier = @"PostCell";
    
    VXThreadDetailCell *cell;
    VXPostCell *pcell;
    
    if (row == 0)
    {
        
        cell = (VXThreadDetailCell *)[tableView dequeueReusableCellWithIdentifier:tcellIdentifier];
        
        if (nil == cell)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VXThreadDetailCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        cell.notename.text = [thread objectForKey:@"nodename"];
        cell.author.text = [thread objectForKey:@"author"];
        cell.posthit.text = [thread objectForKey:@"posthit"];
        cell.subject.text = [thread objectForKey:@"subject"];
        [cell.subject sizeToFit];
        
        NSString *content = @"";
        if ([thread objectForKey:@"content"])
        {
            content = [thread objectForKey:@"content"];
        }
        
        cell.content.delegate = self;
        RTLabelComponentsStructure *components = [RCLabel extractTextStyle:content];
        cell.content.componentsAndPlainText = components;
        
        CGRect contentframe = cell.content.frame;
        CGSize optimalSize = [cell.content optimumSize];
        contentframe.size.height = optimalSize.height;
        cell.content.frame = contentframe;
        
        if (cell.subject.frame.size.height > 36) {
            [cell.content setFrame:CGRectMake(cell.content.frame.origin.x, cell.content.frame.origin.y + cell.subject.frame.size.height - 36, cell.content.frame.size.width, cell.content.frame.size.height)];
        }
        [cell.avatar setImageWithURL:[NSURL URLWithString:[thread objectForKey:@"avatar"]] placeholderImage:[UIImage imageNamed:@"avatar"]];
        cell.avatar.clipsToBounds = YES;
        cell.avatar.layer.cornerRadius = 24;
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    else
    {
        pcell = (VXPostCell *)[tableView dequeueReusableCellWithIdentifier:pcellIdentifier];
        
        if (nil == pcell)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VXPostCell" owner:self options:nil];
            pcell = [nib objectAtIndex:0];
        }
        
        pcell.content.text = [[posts objectAtIndex:row - 1] objectForKey:@"content"];
        [pcell.content sizeToFit];
        pcell.author.text = [[posts objectAtIndex:row - 1] objectForKey:@"author"];
        pcell.posted.text = [[posts objectAtIndex:row - 1] objectForKey:@"posted"];
        [pcell.avatar setImageWithURL:[NSURL URLWithString:[[posts objectAtIndex:row - 1] objectForKey:@"avatar"]] placeholderImage:[UIImage imageNamed:@"avatar"]];
        pcell.avatar.clipsToBounds = YES;
        pcell.avatar.layer.cornerRadius = 20;
        
        [pcell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return pcell;
    }
    
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    if (row == 0)
    {
        VXThreadDetailCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        
        CGFloat height = 90;
        
        if (cell.subject.frame.size.height > 36) {
            height = height + cell.subject.frame.size.height - 36;
        }
        
        if (cell.content.frame.size.height > 18) {
            height = height + cell.content.frame.size.height - 20;
        }
        
        return  height;
    }
    else
    {
        VXPostCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        
        if (cell.content.frame.size.height > 18) {
            return 60 + cell.content.frame.size.height - 30;
        }
        
        return 60;
    }
    
    return 60;
}

- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSString*)url
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}
@end
