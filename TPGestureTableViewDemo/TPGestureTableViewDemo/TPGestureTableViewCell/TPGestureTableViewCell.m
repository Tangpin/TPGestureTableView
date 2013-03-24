//
//  TPGestureTableViewCell.m
//  TangGestureTableViewDemo
//
//  Created by kavin on 13-3-16.
//  Copyright (c) 2013年 TangPin. All rights reserved.
//

#import "TPGestureTableViewCell.h"
#import <QuartzCore/QuartzCore.h>


@interface SeperateLine : UIView

@end

@implementation SeperateLine

-(void)drawRect:(CGRect)rect{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    CGContextSetLineWidth(context, 1);
    
    CGContextSetStrokeColorWithColor(context,[UIColor whiteColor].CGColor);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context,0, 1);
    CGContextAddLineToPoint(context, self.bounds.size.width, 0);
    CGContextStrokePath(context);
    
    CGContextSetStrokeColorWithColor(context,[UIColor lightGrayColor].CGColor);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context,0, 0);
    CGContextAddLineToPoint(context, self.bounds.size.width, 0);
    CGContextStrokePath(context);


}

@end

#define kMinimumVelocity  self.contentView.frame.size.width*1.5
#define kMinimumPan       60.0
#define kBOUNCE_DISTANCE  7.0

typedef enum {
    LMFeedCellDirectionNone=0,
	LMFeedCellDirectionRight,
	LMFeedCellDirectionLeft,
} LMFeedCellDirection;

@interface TPGestureTableViewCell ()

//flag
@property (nonatomic,retain) UIPanGestureRecognizer *panGesture;
@property (nonatomic,assign) CGFloat initialHorizontalCenter;
@property (nonatomic,assign) CGFloat initialTouchPositionX;

@property (nonatomic,assign) LMFeedCellDirection lastDirection;
@property (nonatomic,assign) CGFloat originalCenter;

//ui
@property (nonatomic,retain) SeperateLine *seperateLine;
@property (nonatomic,retain) UIView *bottomRightView;
@property (nonatomic,retain) UIView *bottomLeftView;
@property (nonatomic,retain) UILabel *titleLabel;
@property (nonatomic,retain) UITextView *detailTextView;

@end


@implementation TPGestureTableViewCell
@synthesize delegate;
@synthesize initialHorizontalCenter=_initialHorizontalCenter;
@synthesize initialTouchPositionX=_initialTouchPositionX;
@synthesize bottomLeftView=_bottomLeftView;
@synthesize bottomRightView=_bottomRightView;
@synthesize seperateLine=_seperateLine;
@synthesize itemData=_itemData;


-(void)dealloc{
    self.itemData=nil;
    self.titleLabel=nil;
    self.detailTextView=nil;
    self.panGesture=nil;
    self.bottomRightView=nil;
    self.bottomLeftView=nil;
    self.seperateLine=nil;
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor whiteColor];
        _currentStatus=kFeedStatusNormal;
        
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor darkGrayColor];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_titleLabel];
        
        _detailTextView = [[UITextView alloc]initWithFrame:CGRectZero];
        _detailTextView.backgroundColor = [UIColor clearColor];
        _detailTextView.textColor = [UIColor grayColor];
        _detailTextView.font = [UIFont systemFontOfSize:13];
        _detailTextView.hidden=YES;
        [_detailTextView setEditable:NO];

        [self.contentView addSubview:_detailTextView];
        
        _seperateLine = [[SeperateLine alloc]initWithFrame:CGRectZero];
        _seperateLine.backgroundColor=[UIColor clearColor];
        [self.contentView addSubview:_seperateLine];
        
        _originalCenter=ceil(self.bounds.size.width / 2);
        
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandle:)];
		_panGesture.delegate = self;
        [self addGestureRecognizer:_panGesture];
        
    }
    return self;
}


-(void)layoutBottomView{
    if(!self.bottomRightView){
        _bottomRightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        _bottomRightView.backgroundColor = [UIColor lightGrayColor];
        [self insertSubview:_bottomRightView atIndex:0];
    }
    if(!self.bottomLeftView){
        _bottomLeftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        _bottomLeftView.backgroundColor =  [UIColor colorWithRed:132/255.0 green:176/255.0 blue:201/255.0 alpha:1.0];

        [self insertSubview:_bottomLeftView atIndex:0];
    }
}


-(void)setItemData:(TPDataModel *)itemData{
    [itemData retain];
    [_itemData release];
    _itemData=itemData;
    [self setNeedsLayout];
    
}




-(void)layoutSubviews{
    [super layoutSubviews];
    
    _titleLabel.frame = CGRectMake(15, 15, 300, 30);
    _titleLabel.text = _itemData.title;
    _seperateLine.frame=CGRectMake(0, 0, self.frame.size.width,1);
    
    if(_itemData.isExpand==YES){
        _detailTextView.frame = CGRectMake(14, 40, 300, 60);
        _detailTextView.text = _itemData.detail;
        _detailTextView.hidden=NO;
        
    }
    else{
        _detailTextView.text=@"";
        _detailTextView.hidden=YES;
    }
}


- (void)togglePanelWithFlag{
    switch (_currentStatus) {
        case kFeedStatusLeftExpanding:
        {
            _bottomRightView.alpha=0.0f;
            _bottomLeftView.alpha=1.0f;
        }
            break;
        case kFeedStatusRightExpanding:
        {
            _bottomRightView.alpha=1.0f;
            _bottomLeftView.alpha=0.0f;
        }
            break;
        case kFeedStatusNormal:{
            [_bottomRightView removeFromSuperview];
            self.bottomRightView=nil;
            [_bottomLeftView removeFromSuperview];
            self.bottomLeftView=nil;
        }
        default:
            break;
    }

}



- (void)panGestureHandle:(UIPanGestureRecognizer *)recognizer
{

    //begin pan...
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        _initialTouchPositionX = [recognizer locationInView:self].x;
        _initialHorizontalCenter = self.contentView.center.x;
        if(_currentStatus==kFeedStatusNormal){
            [self layoutBottomView];
        }
        if ([self.delegate respondsToSelector:@selector(cellDidBeginPan:)]){
            [self.delegate cellDidBeginPan:self];
        }
        
        
    }else if (recognizer.state == UIGestureRecognizerStateChanged) { //status change
        
        
        CGFloat panAmount  = _initialTouchPositionX - [recognizer locationInView:self].x;
        CGFloat newCenterPosition     = _initialHorizontalCenter - panAmount;
        CGFloat centerX               = self.contentView.center.x;

        
        if(centerX>_originalCenter && _currentStatus!=kFeedStatusLeftExpanding){
            _currentStatus = kFeedStatusLeftExpanding;
            [self togglePanelWithFlag];
        }
        else if(centerX<_originalCenter && _currentStatus!=kFeedStatusRightExpanding){
            _currentStatus = kFeedStatusRightExpanding;
            [self togglePanelWithFlag];

        }
        
        if (panAmount > 0){
            _lastDirection = LMFeedCellDirectionLeft;
        }
        else{
            _lastDirection = LMFeedCellDirectionRight;
        }
        
        if (newCenterPosition > self.bounds.size.width + _originalCenter){
            newCenterPosition = self.bounds.size.width + _originalCenter;
        }
        else if (newCenterPosition < -_originalCenter){
            newCenterPosition = -_originalCenter;
        }
        CGPoint center = self.contentView.center;
        center.x = newCenterPosition;
        self.contentView.layer.position = center;
        
        
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded ||
            recognizer.state == UIGestureRecognizerStateCancelled){
        
        CGPoint translation = [recognizer translationInView:self];
        CGFloat velocityX = [recognizer velocityInView:self].x;
        
        //判断是否push view
        BOOL isNeedPush = (fabs(velocityX) > kMinimumVelocity);
        

        isNeedPush |= ((_lastDirection == LMFeedCellDirectionLeft && translation.x < -kMinimumPan) ||
                       (_lastDirection== LMFeedCellDirectionRight && translation.x > kMinimumPan));
        
        if (velocityX > 0 && _lastDirection == LMFeedCellDirectionLeft){
            isNeedPush = NO;
        }
        
        else if (velocityX < 0 && _lastDirection == LMFeedCellDirectionRight){
            isNeedPush = NO;
        }
        
        if (isNeedPush && !self.revealing) {
            
            if(_lastDirection==LMFeedCellDirectionRight){
                _currentStatus = kFeedStatusLeftExpanding;
                [self togglePanelWithFlag];
                
            }
            else{
                _currentStatus = kFeedStatusRightExpanding;
                [self togglePanelWithFlag];
            }
            [self _slideOutContentViewInDirection:_lastDirection];
            [self _setRevealing:YES];
            
        }
        else if (self.revealing && translation.x != 0) {
            
            LMFeedCellDirection direct = _currentStatus==kFeedStatusRightExpanding?LMFeedCellDirectionLeft:LMFeedCellDirectionRight;
            
            [self _slideInContentViewFromDirection:direct];
            [self _setRevealing:NO];
            
        }
        else if (translation.x != 0) {
            // Figure out which side we've dragged on.
            LMFeedCellDirection finalDir = LMFeedCellDirectionRight;
            if (translation.x < 0)
                finalDir = LMFeedCellDirectionLeft;
            [self _slideInContentViewFromDirection:finalDir];
            [self _setRevealing:NO];
        }
    }
    
}

#pragma mark -
#pragma mark revealing setter
- (void)setRevealing:(BOOL)revealing
{
	if (_revealing == revealing) {
		return;
    }
	[self _setRevealing:revealing];
	
	if (self.revealing) {
		[self _slideOutContentViewInDirection:_lastDirection];
	} else {
		[self _slideInContentViewFromDirection:_lastDirection];
    }
}

- (void)_setRevealing:(BOOL)revealing
{
	_revealing=revealing;
	if (self.revealing && [self.delegate respondsToSelector:@selector(cellDidReveal:)])
		[self.delegate cellDidReveal:self];
}



#pragma mark
#pragma mark - ContentView Sliding
- (void)_slideInContentViewFromDirection:(LMFeedCellDirection)direction
{
    
	CGFloat bounceDistance;

	if (self.contentView.center.x == _originalCenter)
		return;
	
	switch (direction) {
		case LMFeedCellDirectionRight:
			bounceDistance = kBOUNCE_DISTANCE;
			break;
		case LMFeedCellDirectionLeft:
			bounceDistance = -kBOUNCE_DISTANCE;
			break;
		default:
			break;
	}
	
	[UIView animateWithDuration:0.1
						  delay:0
						options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction
					 animations:^{
                         self.contentView.center = CGPointMake(_originalCenter, self.contentView.center.y);
                     }
					 completion:^(BOOL f) {
						 [UIView animateWithDuration:0.1 delay:0
											 options:UIViewAnimationOptionCurveEaseOut
										  animations:^{ self.contentView.frame = CGRectOffset(self.contentView.frame, bounceDistance, 0); }
										  completion:^(BOOL f) {
                                              [UIView animateWithDuration:0.1 delay:0
                                                                  options:UIViewAnimationOptionCurveEaseIn
                                                               animations:^{ self.contentView.frame = CGRectOffset(self.contentView.frame, -bounceDistance, 0); }
                                                               completion:^(BOOL f){
                                                                   _currentStatus=kFeedStatusNormal;
                                                                   [self togglePanelWithFlag];
                                                               }];
                                          }];
                     }];
}



- (void)_slideOutContentViewInDirection:(LMFeedCellDirection)direction;
{
	CGFloat newCenterX;
    CGFloat bounceDistance;
    switch (direction) {
        case LMFeedCellDirectionLeft:{
            newCenterX = - _originalCenter/2;
            bounceDistance = -kBOUNCE_DISTANCE;
            _currentStatus=kFeedStatusLeftExpanded;
        }
            break;
        case LMFeedCellDirectionRight:{
            newCenterX = self.contentView.frame.size.width + _originalCenter/2;
            bounceDistance = kBOUNCE_DISTANCE;
            _currentStatus=kFeedStatusRightExpanded;
        }
            break;
        default:
            break;
    }
    
	[UIView animateWithDuration:0.1
						  delay:0
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
                         self.contentView.center = CGPointMake(newCenterX, self.contentView.center.y);
                     }
                     completion:^(BOOL f) {
						 [UIView animateWithDuration:0.1 delay:0
											 options:UIViewAnimationOptionCurveEaseIn
										  animations:^{
                                              self.contentView.frame = CGRectOffset(self.contentView.frame, -bounceDistance, 0);
                                          }
										  completion:^(BOOL f) {
											  [UIView animateWithDuration:0.1 delay:0
                                                                  options:UIViewAnimationOptionCurveEaseIn
                                                               animations:^{
                                                                   self.contentView.frame = CGRectOffset(self.contentView.frame, bounceDistance, 0);
                                                               }
                                                               completion:NULL];
										  }];
                     }];
}




#pragma mark
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	if (gestureRecognizer == _panGesture) {
		UIScrollView *superview = (UIScrollView *)self.superview;
		CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:superview];
		// Make it scrolling horizontally
		return ((fabs(translation.x) / fabs(translation.y) > 1) ? YES : NO &&
                (superview.contentOffset.y == 0.0 && superview.contentOffset.x == 0.0));
	}
	return YES;
}



@end
