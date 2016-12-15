//
//  RoutePathDetailViewController.m
//  Drive-Route-Demo
//
//  Created by eidan on 16/11/28.
//  Copyright © 2016年 autonavi. All rights reserved.
//

#import "RoutePathDetailViewController.h"
#import "RoutePathDetailTableViewCell.h"
#import <AMapSearchKit/AMapSearchKit.h>

@interface RoutePathDetailViewController ()<UITableViewDelegate,UITableViewDataSource>

//data
@property (strong, nonatomic) NSMutableArray *routeDetailDataArray;  //路径步骤数组
@property (copy, nonatomic) NSDictionary *drivingImageDic;  //根据AMapStep.action获得对应的图片名字

//xib views
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *timeInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *taxiCostInfoLabel;


@end

@implementation RoutePathDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.drivingImageDic = @{
                         @"开始":@"start",
                         @"结束":@"end",
                         @"右转":@"right",
                         @"左转":@"left",
                         @"直行":@"straight",
                         @"向右前方行驶":@"rightFront",
                         @"向左前方行驶":@"leftFront",
                         @"向左后方行驶":@"leftRear",
                         @"向右后方行驶":@"rightRear",
                         @"左转调头":@"leftRear",
                         @"靠左":@"leftFront",
                         @"靠右":@"rightFront",
                         @"进入环岛":@"straight",
                         @"离开环岛":@"straight",
                         @"减速行驶":@"dottedStraight",
                         @"插入直行":@"straight",
                         @"":@"straight",
                         };
    
    [self setUpViews];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)setUpViews {
    
    self.tableView.tableHeaderView = self.headerView;
    [self.tableView registerNib:[UINib nibWithNibName:@"RoutePathDetailTableViewCell" bundle:nil] forCellReuseIdentifier:RoutePathDetailTableViewCellIdentifier];
    self.tableView.rowHeight = 54;
    
    NSInteger hours = self.path.duration / 3600;
    NSInteger minutes = (NSInteger)(self.path.duration / 60) % 60;
    self.timeInfoLabel.text = [NSString stringWithFormat:@"%u小时%u分钟（%u公里）",(unsigned)hours,(unsigned)minutes,(unsigned)self.path.distance / 1000];
    self.taxiCostInfoLabel.text = [NSString stringWithFormat:@"打车约%.0f元",self.route.taxiCost];
    
    AMapStep *startStep = [AMapStep new];
    startStep.action = @"开始"; //导航主要动作，用来标示图标
    startStep.instruction = @"开始";  //行走指示
    
    AMapStep *endStep = [AMapStep new];
    endStep.action = @"结束";
    endStep.instruction = @"抵达";
    
    self.routeDetailDataArray = @[].mutableCopy;
    [self.routeDetailDataArray addObject:startStep];
    [self.routeDetailDataArray addObjectsFromArray:self.path.steps];
    [self.routeDetailDataArray addObject:endStep];

}

#pragma -mark UITableView Delegate and DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.routeDetailDataArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RoutePathDetailTableViewCell *cell = (RoutePathDetailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:RoutePathDetailTableViewCellIdentifier forIndexPath:indexPath];
    
    AMapStep *step = [self.routeDetailDataArray objectAtIndex:indexPath.row];
    
    cell.infoLabel.text = step.instruction;
    cell.actionImageView.image = [UIImage imageNamed:[self.drivingImageDic objectForKey:step.action]];
    
    cell.topVerticalLine.hidden = indexPath.row == 0;
    cell.bottomVerticalLine.hidden = indexPath.row == self.routeDetailDataArray.count - 1;
    
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark Xib Btn Click

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
