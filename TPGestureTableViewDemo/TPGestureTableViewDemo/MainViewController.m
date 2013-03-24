//
//  ViewController.m
//  TangGestureTableViewDemo
//
//  Created by kavin on 13-3-16.
//  Copyright (c) 2013年 TangPin. All rights reserved.
//

#import "MainViewController.h"
#import "TPGestureTableViewCell.h"
#import "TPDataModel.h"

@interface MainViewController ()

@property (nonatomic,retain) UITableView *myTableView;
@property (nonatomic,retain) NSMutableArray *dataArray;
@property (nonatomic,retain) TPGestureTableViewCell *currentCell;
@end

@implementation MainViewController

-(void)dealloc{
    self.myTableView=nil;
    self.dataArray=nil;
    self.currentCell=nil;
    [super dealloc];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *path=[[NSBundle mainBundle] pathForResource:@"TableViewData" ofType:@"plist"];
    _dataArray = [[NSMutableArray alloc]init];
    NSArray *sourceArray = [[NSArray alloc] initWithContentsOfFile:path];
    
    for(int i=0;i<[sourceArray count];i++){
        NSDictionary *dict = [sourceArray objectAtIndex:i];
        TPDataModel *item = [[TPDataModel alloc]init];
        item.title = [dict objectForKey:@"Title"];
        item.detail = [dict objectForKey:@"Detail"];
        item.isExpand=NO;
        [_dataArray addObject:item];
        [item release];
    }
    [sourceArray release];

	_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0,
                                                                self.view.frame.size.width,
                                                                self.view.frame.size.height)];
    _myTableView.delegate=self;
    _myTableView.dataSource=self;
    _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _myTableView.backgroundColor=[UIColor darkGrayColor];
    [self.view addSubview:_myTableView];
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark
#pragma mark UITableViewDatasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TPDataModel *item=(TPDataModel*)[_dataArray objectAtIndex:indexPath.row];
    if(item.isExpand==NO){
        return 60;
    }
    return 100;
}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataArray count];
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"LomemoBasicCell";
    TPGestureTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[TPGestureTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        cell.delegate=self;
    }
    TPDataModel *item=(TPDataModel*)[_dataArray objectAtIndex:indexPath.row];
    cell.itemData=item;
    return cell;
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TPGestureTableViewCell *cell = (TPGestureTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    if(cell.revealing==YES){
        cell.revealing=NO;
        return;
    }
    TPDataModel *item=(TPDataModel*)[_dataArray objectAtIndex:indexPath.row];
    item.isExpand=!item.isExpand;
    cell.itemData=item;
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark
#pragma mark TPGestureTableViewCellDelegate
- (void)cellDidBeginPan:(TPGestureTableViewCell *)cell{
    
}

- (void)cellDidReveal:(TPGestureTableViewCell *)cell{
    if(self.currentCell!=cell){
        self.currentCell.revealing=NO;
        self.currentCell=cell;
    }

}



@end
