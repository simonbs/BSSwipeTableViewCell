//
//  BSSwipeTableViewCell.m
//  Listen
//
//  Created by Simon Støvring on 19/09/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import "BSSwipeTableViewCell.h"

#define BSDefaultDraggingDirection -1
#define BSBounceAnimationDuration 0.30f
#define BSAnimationDurationLowLimit 0.25f
#define BSAnimationDurationHighLimit 0.10f
#define BSBackgroundColorAnimationDuration 0.15f

@interface BSSwipeTableViewCell ()
@property (nonatomic, strong) UIView *colorView;
@property (nonatomic, strong) UIView *sideView;
@property (nonatomic, assign) BSSwipeTableViewCellDirection draggingDirection;
@property (nonatomic, assign, getter = isActive) BOOL active;
@end

@implementation BSSwipeTableViewCell

#pragma mark -
#pragma mark Lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self initialize];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self initialize];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self initialize];
    }
    
    return self;
}

- (id)init
{
    if (self = [super init])
    {
        [self initialize];
    }
    
    return self;
}

- (void)initialize
{
    self.active = NO;
    
    self.revealLeft = YES;
    self.revealRight = YES;
    
    self.leftMode = BSSwipeTableViewCellModeReset;
    self.rightMode = BSSwipeTableViewCellModeReset;
    
    self.leftActivationPercentage = 0.25f;
    self.rightActivationPercentage = 0.25f;
    self.defaultBackgroundColor = [UIColor lightGrayColor];
    
    self.colorView = [[UIView alloc] initWithFrame:self.bounds];
    self.colorView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self insertSubview:self.colorView atIndex:0];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGesture.delegate = self;
    panGesture.delaysTouchesBegan = NO;
    [self addGestureRecognizer:panGesture];
    
    self.draggingDirection = BSDefaultDraggingDirection;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.active = NO;
    self.colorView.backgroundColor = [UIColor clearColor];
    
    [self removeSideView];
    
    self.draggingDirection = BSDefaultDraggingDirection;
}

- (void)dealloc
{
    self.colorView = nil;
    self.sideView = nil;
    self.defaultBackgroundColor = nil;
    self.leftBackgroundColor = nil;
    self.rightBackgroundColor = nil;
}

#pragma mark -
#pragma mark Gestures

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture
{
    UIGestureRecognizerState state = gesture.state;
    CGPoint translation = [gesture translationInView:self];
    CGPoint velocity = [gesture velocityInView:self];
    
    if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged)
    {
        CGRect frame = self.contentView.frame;
        CGPoint pos = frame.origin;
        pos.x += translation.x;
            
        // Don't do anything if trying to drag left and cannot drag left
        if (pos.x > 0.0f && !self.canRevealLeft)
        {
            return;
        }
        
        // Don't do anything if trying to drag right and cannot drag right
        if (pos.x < 0.0f && !self.canRevealRight)
        {
            return;
        }
        
        frame.origin = pos;
        self.contentView.frame = frame;
        
        [gesture setTranslation:CGPointZero inView:self];
        
        CGFloat offset = self.contentView.frame.origin.x;
        CGFloat percentage = [self percentageForOffset:offset];
        
        // We use positive/negative percentage to determine direction
        BSSwipeTableViewCellDirection direction = [self directionForPercentage:percentage];
        
        if (state == UIGestureRecognizerStateBegan || direction != self.draggingDirection)
        {
            // Inform delegate that dragging started or direction changed (that is, dragging started in a new direction)
            if ([self.delegate respondsToSelector:@selector(swipeTableViewCell:beganDraggingInDirection:)])
            {
                [self.delegate swipeTableViewCell:self beganDraggingInDirection:direction];
            }
        }
        
        if (direction != self.draggingDirection)
        {
            // Started dragging the other way
            [self removeSideView];
            
            if ([self.delegate respondsToSelector:@selector(swipeTableViewCell:viewForSwipingInDirection:)])
            {
                self.sideView = [self.delegate swipeTableViewCell:self viewForSwipingInDirection:direction];
                [self.colorView addSubview:self.sideView];
            }
        }
        
        self.draggingDirection = direction;
        
        percentage = fabsf(percentage); // We are interested in absolute percentage and use the dragging direction from now on
        [self reactToPercentage:percentage];
        
        // Inform delegate that drag changed
        if ([self.delegate respondsToSelector:@selector(swipeTableViewCell:didDragToPercentage:inDirection:)])
        {
            [self.delegate swipeTableViewCell:self didDragToPercentage:percentage inDirection:direction];
        }
    }
    else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled)
    {
        CGFloat offset = self.contentView.frame.origin.x;
        CGFloat percentage = fabsf([self percentageForOffset:offset]);

        // Inform delegate the the dragging stopped
        if ([self.delegate respondsToSelector:@selector(swipeTableViewCell:stoppedDraggingOnPercentage:inDirection:)])
        {
            [self.delegate swipeTableViewCell:self stoppedDraggingOnPercentage:percentage inDirection:self.draggingDirection];
        }
        
        if (self.draggingDirection == BSSwipeTableViewCellDirectionRight && self.leftMode == BSSwipeTableViewCellModeExit && percentage > self.leftActivationPercentage)
        {
            [self exitInDirection:BSSwipeTableViewCellDirectionRight fromPercentage:percentage withVelocity:velocity];
        }
        else if (self.draggingDirection == BSSwipeTableViewCellDirectionLeft && self.rightMode == BSSwipeTableViewCellModeExit && percentage > self.rightActivationPercentage)
        {
            [self exitInDirection:BSSwipeTableViewCellDirectionLeft fromPercentage:percentage withVelocity:velocity];
        }
        else
        {
            [self bounceToOriginFromPercentage:percentage draggedInDirection:self.draggingDirection];
            
            [UIView animateWithDuration:0.25f animations:^{
                [self moveSideViewWithPercentage:0.0f];
            }];
        }
        
        self.draggingDirection = BSDefaultDraggingDirection;
    }
    else if (state == UIGestureRecognizerStateFailed)
    {
        self.draggingDirection = BSDefaultDraggingDirection;
    }
}

#pragma mark -
#pragma mark Helpers

- (CGFloat)percentageForOffset:(CGFloat)offset
{
    CGFloat percentage = offset / CGRectGetWidth(self.contentView.frame);
    
    if (percentage < -1.0f)
    {
        percentage = -1.0f;
    }
    else if (percentage > 1.0f)
    {
        percentage = 1.0f;
    }
    
    return percentage;
}

- (CGFloat)sideViewOffsetWithPercentage:(CGFloat)percentage
{
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat offset = percentage * width;
    
    if (offset < -width)
    {
        offset = -width;
    }
    else if (offset > width)
    {
        offset = width;
    }
    
    return offset;
}

- (BSSwipeTableViewCellDirection)directionForPercentage:(CGFloat)percentage
{
    return (percentage > 0.0f) ? BSSwipeTableViewCellDirectionRight : BSSwipeTableViewCellDirectionLeft;
}

- (UIColor *)colorForPercentage:(CGFloat)percentage
{
    if (self.draggingDirection == BSSwipeTableViewCellDirectionRight && [self isActivePercentage:percentage forDirection:BSSwipeTableViewCellDirectionRight])
    {
        return self.leftBackgroundColor;
    }
    else if (self.draggingDirection == BSSwipeTableViewCellDirectionLeft && [self isActivePercentage:percentage forDirection:BSSwipeTableViewCellDirectionLeft])
    {
        return self.rightBackgroundColor;
    }
    
    return self.defaultBackgroundColor;
}

- (NSTimeInterval)animationDurationWithVelocity:(CGPoint)velocity
{
    CGFloat width = CGRectGetWidth(self.bounds);
    NSTimeInterval animationDurationDiff = BSAnimationDurationHighLimit - BSAnimationDurationLowLimit;
    CGFloat horizontalVelocity = velocity.x;
    
    if (horizontalVelocity < -width)
    {
        horizontalVelocity = -width;
    }
    else if (horizontalVelocity > width)
    {
        horizontalVelocity = width;
    }
    
    return (BSAnimationDurationHighLimit + BSAnimationDurationLowLimit) - fabs(((horizontalVelocity / width) * animationDurationDiff));
}

- (BOOL)isActivePercentage:(CGFloat)percentage forDirection:(BSSwipeTableViewCellDirection)direction
{
    if ((direction == BSSwipeTableViewCellDirectionRight && percentage > self.leftActivationPercentage) ||
        (direction == BSSwipeTableViewCellDirectionLeft && percentage > self.rightActivationPercentage))
    {
        return YES;
    }
    
    return NO;
}

#pragma mark -
#pragma mark Actions

- (void)reactToPercentage:(CGFloat)percentage
{
    if (self.sideView)
    {
        [self moveSideViewWithPercentage:percentage];
    }
    
    [UIView animateWithDuration:BSBackgroundColorAnimationDuration delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.colorView.backgroundColor = [self colorForPercentage:percentage];
    } completion:nil];
    
    BOOL active = [self isActivePercentage:percentage forDirection:self.draggingDirection];
    if (active != self.active)
    {
        if (active)
        {
            if ([self.delegate respondsToSelector:@selector(swipeTableViewCell:didActivateInDirection:)])
            {
                [self.delegate swipeTableViewCell:self didActivateInDirection:self.draggingDirection];
            }
        }
        else
        {
            if ([self.delegate respondsToSelector:@selector(swipeTableViewCell:didDeactivateInDirection:)])
            {
                [self.delegate swipeTableViewCell:self didDeactivateInDirection:self.draggingDirection];
            }
        }
        
        self.active = active;
    }
}

- (void)moveSideViewWithPercentage:(CGFloat)percentage
{
    CGPoint position = self.sideView.frame.origin;
    position.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(self.sideView.bounds)) * 0.50f;

    CGFloat offset = CGRectGetWidth(self.bounds) * percentage;
    
    if (self.draggingDirection == BSSwipeTableViewCellDirectionRight && offset < CGRectGetWidth(self.sideView.bounds))
    {
        position.x = 0.0f;
    }
    else if (self.draggingDirection == BSSwipeTableViewCellDirectionRight && offset >= CGRectGetWidth(self.sideView.bounds))
    {
        position.x = offset - CGRectGetWidth(self.sideView.bounds);
    }
    else if (self.draggingDirection == BSSwipeTableViewCellDirectionLeft && offset < CGRectGetWidth(self.sideView.bounds))
    {
        position.x = CGRectGetWidth(self.bounds) - CGRectGetWidth(self.sideView.bounds);
    }
    else if (self.draggingDirection == BSSwipeTableViewCellDirectionLeft && offset >= CGRectGetWidth(self.sideView.bounds))
    {
        position.x = CGRectGetWidth(self.bounds) - offset;
    }
    
    CGFloat alpha = offset / CGRectGetWidth(self.sideView.bounds);
    if (alpha < 0.0f)
    {
        alpha = 0.0f;
    }
    else if (alpha > 1.0f)
    {
        alpha = 1.0f;
    }
    
    self.sideView.alpha = alpha;
    
    CGRect frame = self.sideView.frame;
    frame.origin = position;
    self.sideView.frame = frame;
}

- (void)removeSideView
{
    if (self.sideView)
    {
        [self.sideView removeFromSuperview];
        self.sideView = nil;
    }
}

- (void)bounceToOriginFromPercentage:(CGFloat)percentage draggedInDirection:(BSSwipeTableViewCellDirection)direction
{
    [UIView animateWithDuration:BSBounceAnimationDuration delay:0.0f usingSpringWithDamping:0.70f initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGRect frame = self.contentView.frame;
        frame.origin.x = 0.0f;
        self.contentView.frame = frame;
    } completion:^(BOOL finished) {
        if (finished)
        {
            [self removeSideView];
            
            self.active = NO;
            self.colorView.backgroundColor = [UIColor clearColor];
            
            // Inform delegate that the drag completed (released in active state)
            if ((direction == BSSwipeTableViewCellDirectionRight && percentage >= self.leftActivationPercentage) ||
                (direction == BSSwipeTableViewCellDirectionLeft && percentage >= self.rightActivationPercentage))
            {
                if ([self.delegate respondsToSelector:@selector(swipeTableViewCell:completedInDirection:)])
                {
                    [self.delegate swipeTableViewCell:self completedInDirection:direction];
                }
            }
            
            // Inform delegate that the content view was reset
            if ([self.delegate respondsToSelector:@selector(swipeTableViewCell:didResetFromDirection:)])
            {
                [self.delegate swipeTableViewCell:self didResetFromDirection:direction];
            }
        }
    }];
}

- (void)exitInDirection:(BSSwipeTableViewCellDirection)direction fromPercentage:(CGFloat)percentage withVelocity:(CGPoint)velocity
{
    CGFloat posX;
    if (direction == BSSwipeTableViewCellDirectionRight)
    {
        posX = CGRectGetWidth(self.bounds);
    }
    else
    {
        posX = -CGRectGetWidth(self.bounds);
    }
    
    CGFloat duration = [self animationDurationWithVelocity:velocity];
    [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        CGRect frame = self.contentView.frame;
        frame.origin.x = posX;
        self.contentView.frame = frame;
        
        [self moveSideViewWithPercentage:1.0f];
    } completion:^(BOOL finished) {
        if (finished)
        {
            [self removeSideView];
            
            self.active = NO;
            self.colorView.backgroundColor = self.defaultBackgroundColor;
            
            // Inform delegate that the drag completed (released in active state)
            if ((direction == BSSwipeTableViewCellDirectionRight && percentage >= self.leftActivationPercentage) ||
                (direction == BSSwipeTableViewCellDirectionLeft && percentage >= self.rightActivationPercentage))
            {
                if ([self.delegate respondsToSelector:@selector(swipeTableViewCell:completedInDirection:)])
                {
                    [self.delegate swipeTableViewCell:self completedInDirection:direction];
                }
            }
        }
    }];
}

#pragma mark -
#pragma mark Gesture Recognizer Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gesture
{
    if ([gesture class] == [UIPanGestureRecognizer class])
    {
        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gesture;
        CGPoint velocity = [panGesture velocityInView:self];

        return fabsf(velocity.x) > fabsf(velocity.y);
    }
    
    return NO;
}

@end
