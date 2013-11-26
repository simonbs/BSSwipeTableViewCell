//
//  TableViewController.m
//  Example
//
//  Created by Simon Støvring on 26/11/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import "TableViewController.h"
#import "BSSwipeTableViewCell.h"

#define kRowHeight 66.0f

@interface TableViewController () <BSSwipeTableViewCellDelegate>
@property (nonatomic, strong) UIImageView *currentSwipeImageView;
@property (nonatomic, strong) NSMutableArray *checkedIndexPaths;
@end

@implementation TableViewController

#pragma mark -
#pragma mark Lifecycle

- (id)init
{
    if (self = [super init])
    {
        self.checkedIndexPaths = [NSMutableArray array];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"BSSwipeTableViewCell";
}

- (void)dealloc
{
    self.currentSwipeImageView = nil;
    self.checkedIndexPaths = nil;
}

#pragma mark 
#pragma mark Private Methods

- (void)deleteRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger count = [self.tableView numberOfRowsInSection:0];
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:count - 1 inSection:0];
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView insertRowsAtIndexPaths:@[ newIndexPath ] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView endUpdates];
}

- (void)checkIndexPath:(NSIndexPath *)indexPath
{
    [self.checkedIndexPaths addObject:indexPath];
}

- (void)uncheckIndexPath:(NSIndexPath *)indexPath
{
    [self.checkedIndexPaths removeObject:indexPath];
}

- (NSInteger)indexOfCheckedIndexPath:(NSIndexPath *)indexPath
{
    return [self.checkedIndexPaths indexOfObject:indexPath];
}

- (BOOL)isIndexPathChecked:(NSIndexPath *)indexPath
{
    return ([self indexOfCheckedIndexPath:indexPath] != NSNotFound);
}

- (UIImageView *)swipeImageViewWithImage:(UIImage *)image tintColor:(UIColor *)tintColor
{
    CGRect frame = CGRectMake(0.0f, 0.0f, 50.0f, 50.0f);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.contentMode = UIViewContentModeCenter;
    imageView.image = image;
    imageView.tintColor = tintColor;
    
    return imageView;
}

#pragma mark -
#pragma mark Table View Data Source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    BSSwipeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        cell = [[BSSwipeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = @"BSSwipeTableViewCell";
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.delegate = self;
    cell.revealLeft = YES;
    cell.revealRight = YES;
    cell.defaultBackgroundColor = [UIColor blackColor];
    cell.leftBackgroundColor = [UIColor colorWithRed:0.043 green:0.827 blue:0.094 alpha:1.000];
    cell.rightBackgroundColor = [UIColor colorWithRed:1.000 green:0.231 blue:0.188 alpha:1.000];
    cell.rightMode = BSSwipeTableViewCellModeExit;
    cell.leftMode = BSSwipeTableViewCellModeReset;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kRowHeight;
}

#pragma mark -
#pragma mark Swipe Table View Cell Delegate

- (UIView *)swipeTableViewCell:(BSSwipeTableViewCell *)cell viewForSwipingInDirection:(BSSwipeTableViewCellDirection)direction
{
    UIImage *image = nil;
    UIColor *tintColor = nil;
    if (direction == BSSwipeTableViewCellDirectionLeft)
    {
        image = [UIImage imageNamed:@"Delete"];
        tintColor = [UIColor whiteColor];
    }
    else
    {
        image = [UIImage imageNamed:@"Checkmark"];
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if ([self isIndexPathChecked:indexPath])
        {
            tintColor = [UIColor colorWithRed:0.776 green:0.263 blue:0.988 alpha:1.000];
        }
        else
        {
            tintColor = [UIColor whiteColor];
        }
    }
    
    UIImage *templateImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.currentSwipeImageView = [self swipeImageViewWithImage:templateImage tintColor:tintColor];
    
    return self.currentSwipeImageView;
}

- (void)swipeTableViewCell:(BSSwipeTableViewCell *)cell didResetFromDirection:(BSSwipeTableViewCellDirection)direction
{
    self.currentSwipeImageView = nil;
}

- (void)swipeTableViewCell:(BSSwipeTableViewCell *)cell completedInDirection:(BSSwipeTableViewCellDirection)direction
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if (direction == BSSwipeTableViewCellDirectionLeft)
    {
        [self deleteRowAtIndexPath:indexPath];
        
        if ([self isIndexPathChecked:indexPath])
        {
            [self uncheckIndexPath:indexPath];
        }
    }
    else if (direction == BSSwipeTableViewCellDirectionRight)
    {
        if ([self isIndexPathChecked:indexPath])
        {
            [self uncheckIndexPath:indexPath];
        }
        else
        {
            [self checkIndexPath:indexPath];
        }
    }
}

@end
