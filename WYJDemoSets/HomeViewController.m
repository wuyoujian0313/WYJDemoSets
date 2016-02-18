//
//  HomeViewController.m
//  WYJDemoSets
//
//  Created by wuyj on 16/2/17.
//  Copyright © 2016年 wuyj. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UITableView          *setsTableView;
@property(nonatomic,strong)NSArray              *demoInfos;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"DEMO集";
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self createDemoInfos];
    [self layoutSetsTableView];
}

- (void)createDemoInfos {
    
    NSArray *infos = [[NSArray alloc] initWithObjects:
                      
                      @{@"VCClassName":@"CycleScrollViewVC",@"Name":@"CycleScrollView"},
                      
                      nil];
    
    self.demoInfos = infos;
}

- (void)layoutSetsTableView {
    
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navigationBarHeight, self.view.frame.size.width, self.view.frame.size.height - navigationBarHeight) style:UITableViewStylePlain];
    [self setSetsTableView:tableView];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.view addSubview:tableView];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_demoInfos count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"setsTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    NSDictionary *dic = [_demoInfos objectAtIndex:indexPath.row];
    cell.textLabel.text = [dic objectForKey:@"Name"];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = [_demoInfos objectAtIndex:indexPath.row];
    NSString* className = [dic objectForKey:@"VCClassName"];
    
    Class VCClass = NSClassFromString(className);
    if (VCClass) {
        UIViewController *vc = [[VCClass alloc] init];
        vc.title = [dic objectForKey:@"Name"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
