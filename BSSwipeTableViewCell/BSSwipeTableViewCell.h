//
//  BSSwipeTableViewCell.h
//  Listen
//
//  Created by Simon Støvring on 19/09/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    BSSwipeTableViewCellDirectionLeft = 0,
    BSSwipeTableViewCellDirectionRight,
} BSSwipeTableViewCellDirection;

typedef enum {
    BSSwipeTableViewCellModeReset = 0,
    BSSwipeTableViewCellModeExit,
} BSSwipeTableViewCellMode;

@protocol BSSwipeTableViewCellDelegate;

@interface BSSwipeTableViewCell : UITableViewCell <UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<BSSwipeTableViewCellDelegate> delegate;

@property (nonatomic, strong) UIColor *defaultBackgroundColor;
@property (nonatomic, strong) UIColor *leftBackgroundColor;
@property (nonatomic, strong) UIColor *rightBackgroundColor;

@property (nonatomic, assign) CGFloat leftActivationPercentage;
@property (nonatomic, assign) CGFloat rightActivationPercentage;

@property (nonatomic, assign) BSSwipeTableViewCellMode leftMode;
@property (nonatomic, assign) BSSwipeTableViewCellMode rightMode;

@property (nonatomic, assign, getter = canRevealLeft) BOOL revealLeft;
@property (nonatomic, assign, getter = canRevealRight) BOOL revealRight;

@property (nonatomic, strong, readonly) UIView *sideView;

@end

@protocol BSSwipeTableViewCellDelegate <NSObject>
@optional
- (UIView *)swipeTableViewCell:(BSSwipeTableViewCell *)cell viewForSwipingInDirection:(BSSwipeTableViewCellDirection)direction;
- (void)swipeTableViewCell:(BSSwipeTableViewCell *)cell beganDraggingInDirection:(BSSwipeTableViewCellDirection)direction;
- (void)swipeTableViewCell:(BSSwipeTableViewCell *)cell didDragToPercentage:(CGFloat)percentage inDirection:(BSSwipeTableViewCellDirection)direction;
- (void)swipeTableViewCell:(BSSwipeTableViewCell *)cell stoppedDraggingOnPercentage:(CGFloat)percentage inDirection:(BSSwipeTableViewCellDirection)direction;
- (void)swipeTableViewCell:(BSSwipeTableViewCell *)cell completedInDirection:(BSSwipeTableViewCellDirection)direction;
- (void)swipeTableViewCell:(BSSwipeTableViewCell *)cell didActivateInDirection:(BSSwipeTableViewCellDirection)direction;
- (void)swipeTableViewCell:(BSSwipeTableViewCell *)cell didDeactivateInDirection:(BSSwipeTableViewCellDirection)direction;
- (void)swipeTableViewCell:(BSSwipeTableViewCell *)cell didResetFromDirection:(BSSwipeTableViewCellDirection)direction;
@end
