//
//  TPGestureTableViewCell.h
//  TangGestureTableViewDemo
//
//  Created by kavin on 13-3-16.
//  Copyright (c) 2013年 TangPin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPDataModel.h"

typedef enum {
    kFeedStatusNormal = 0,
    kFeedStatusLeftExpanded,
    kFeedStatusLeftExpanding,
    kFeedStatusRightExpanded,
    kFeedStatusRightExpanding,
}kFeedStatus;

@class TPGestureTableViewCell;

@protocol TPGestureTableViewCellDelegate <NSObject>

- (void)cellDidBeginPan:(TPGestureTableViewCell *)cell;  
- (void)cellDidReveal:(TPGestureTableViewCell *)cell;      

@end

@interface TPGestureTableViewCell : UITableViewCell<UIGestureRecognizerDelegate>

@property (nonatomic,assign) id<TPGestureTableViewCellDelegate> delegate;                     
@property (nonatomic,assign) kFeedStatus currentStatus;                 
@property (nonatomic,assign) BOOL revealing;                            
@property (nonatomic,retain) TPDataModel* itemData;
@end
