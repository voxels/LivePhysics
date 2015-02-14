//
//  DeadEffectNode.m
//  LivePhysics
//
//  Created by Voxels on 2/14/15.
//  Copyright (c) 2015 Noise Derived. All rights reserved.
//

#import "DeadEffectNode.h"

@interface DeadEffectNode ()

@property (strong) SKSpriteNode *spriteNode;
@property (assign) CGSize viewSize;

@end

@implementation DeadEffectNode


- (id) initWithView:(SKView *)skView
{
    self = [self init];
    if( self )
    {
        [self setupSpriteWithView:skView];
    }
    return self;
}


- (id) init
{
    self = [super init];
    if( self )
    {
        [self setShouldEnableEffects:YES];
    }
    return self;
}

- (void) setupSpriteWithView:(SKView *)skView
{
    self.viewSize = CGSizeMake( CGRectGetWidth(skView.bounds), CGRectGetHeight(skView.bounds) );
    self.spriteNode = [[SKSpriteNode alloc] init];
    self.spriteNode.size = skView.bounds.size;
    self.spriteNode.position = CGPointMake(CGRectGetMidX(skView.bounds), CGRectGetMidY(skView.bounds));
    [self addChild:self.spriteNode];
}


- (void) updateSpriteTexture:(SKTexture *)updatedTexture forRect:(CGRect)calculatedRect
{
    self.spriteNode.texture = updatedTexture;
    CGFloat scaleX = (CGRectGetMaxX(calculatedRect) - CGRectGetMinX(calculatedRect)) / self.viewSize.width;
    CGFloat scaleY = (CGRectGetMaxY(calculatedRect) - CGRectGetMinY(calculatedRect)) / self.viewSize.height;
    [self setXScale:scaleX];
    [self setYScale:scaleY];
    [self setPosition:CGPointMake(calculatedRect.origin.x, calculatedRect.origin.y)];
}

@end