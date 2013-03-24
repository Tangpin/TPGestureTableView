#TPGestureTableView

TPGestureTableView is tableview that provides custom tableViewCell(TPGestureTableViewCell) to expland and show the hidden option views by using tap or pan gesture.

##Screenshot

![TPGestureTableView](http://tangp.in/wp-content/uploads/2013/03/tpgesturetableview.png)

##Usage


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

And make sure implementing the heightForRowAtIndexPath and didSelectRowAtIndexPath methods to expland the cell

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TPDataModel *item=(TPDataModel*)[_dataArray objectAtIndex:indexPath.row];
    if(item.isExpand==NO){
        return 60;
    }
    return 100; //explanded height
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


###TPGestureTableViewCell

TPGestureTableViewCell is a custom TableViewCell provides three hidden subviews.

@property (nonatomic,retain) UIView *bottomRightView;
@property (nonatomic,retain) UIView *bottomLeftView;
@property (nonatomic,retain) UITextView *detailTextView;


###Delegate

@protocol TPGestureTableViewCellDelegate <NSObject>

- (void)cellDidBeginPan:(TPGestureTableViewCell *)cell;  
- (void)cellDidReveal:(TPGestureTableViewCell *)cell;      

@end



##License

TPGestureTableView is available under the MIT license. 

