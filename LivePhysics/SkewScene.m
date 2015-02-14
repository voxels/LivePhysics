//
//  SkewScene.m
//  LivePhysics
//
//  Created by Voxels on 2/14/15.
//  Copyright (c) 2015 Noise Derived. All rights reserved.
//

#import "SkewScene.h"

CGFloat kHandleSize = 10;

@interface SkewScene ()

@property SKEffectNode *rootNode;
@property SKSpriteNode *windowNode;
@property SKNode *surfaceNode;
@property SKShapeNode *topLeftHandle;
@property SKShapeNode *topRightHandle;
@property SKShapeNode *bottomLeftHandle;
@property SKShapeNode *bottomRightHandle;
@property SKNode *movingNode;

@property CGPoint lastLocation;

@end


@implementation SkewScene


- (void) didMoveToView:(SKView *)view
{
    [self setupBaseNodes];
    [self setupSurface];
    
}

- (void) setupBaseNodes
{
    self.rootNode = [[SKEffectNode alloc] init];
    [self addChild:self.rootNode];
    
    self.windowNode = [[SKSpriteNode alloc] initWithColor:[SKColor blackColor] size:self.view.frame.size];
    self.windowNode.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    [self.rootNode addChild:self.windowNode];
}

- (void) setupSurface
{
    self.surfaceNode = [[SKNode alloc] init];
    self.surfaceNode.name = @"surface";
    [self.rootNode addChild:self.surfaceNode];
    
    self.topLeftHandle = [SKShapeNode shapeNodeWithCircleOfRadius:kHandleSize];
    self.topLeftHandle.name = @"topLeftVector";
    self.topLeftHandle.position = CGPointMake(CGRectGetMidX(self.view.bounds) - CGRectGetWidth(self.view.bounds) / 10.f, CGRectGetMidY(self.view.bounds) + CGRectGetHeight(self.view.bounds) / 10.f);
    self.topLeftHandle.fillColor = [SKColor whiteColor];
    self.topLeftHandle.zPosition = 1;
    [self.surfaceNode addChild:self.topLeftHandle];
    
    self.topRightHandle = [SKShapeNode shapeNodeWithCircleOfRadius:kHandleSize];
    self.topRightHandle.name = @"topRightVector";
    self.topRightHandle.position = CGPointMake(CGRectGetMidX(self.view.bounds) + CGRectGetWidth(self.view.bounds) / 10.f, CGRectGetMidY(self.view.bounds) + CGRectGetHeight(self.view.bounds) / 10.f);
    self.topRightHandle.fillColor = [SKColor whiteColor];
    self.topRightHandle.zPosition = 1;
    [self.surfaceNode addChild:self.topRightHandle];

    self.bottomRightHandle = [SKShapeNode shapeNodeWithCircleOfRadius:kHandleSize];
    self.bottomRightHandle.name = @"bottomRightVector";
    self.bottomRightHandle.position = CGPointMake(CGRectGetMidX(self.view.bounds) + CGRectGetWidth(self.view.bounds) / 10.f, CGRectGetMidY(self.view.bounds) - CGRectGetHeight(self.view.bounds) / 10.f);
    self.bottomRightHandle.fillColor = [SKColor whiteColor];
    self.bottomRightHandle.zPosition = 1;
    [self.surfaceNode addChild:self.bottomRightHandle];

    self.bottomLeftHandle = [SKShapeNode shapeNodeWithCircleOfRadius:kHandleSize];
    self.bottomLeftHandle.name = @"bottomLeftVector";
    self.bottomLeftHandle.position = CGPointMake(CGRectGetMidX(self.view.bounds) - CGRectGetWidth(self.view.bounds) / 10.f, CGRectGetMidY(self.view.bounds) - CGRectGetHeight(self.view.bounds) / 10.f);
    self.bottomLeftHandle.fillColor = [SKColor whiteColor];
    self.bottomLeftHandle.zPosition = 1;
    [self.surfaceNode addChild:self.bottomLeftHandle];
}


- (void) handleMouseEventForNode:(SKNode *)node atPoint:(CGPoint)location
{
    node.position = location;
}


#pragma mark - Mouse Events

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void) mouseDown:(NSEvent *)theEvent
{
    [super mouseDown:theEvent];
    CGPoint positionInScene = [theEvent locationInNode:self.surfaceNode];
    
    SKNode *node = [self.surfaceNode nodeAtPoint:positionInScene];
    if( ![node.name isEqualToString:@"surface"] )
    {
        self.movingNode = node;
    }
}

- (void) mouseDragged:(NSEvent *)theEvent
{
    CGPoint positionInScene = [theEvent locationInNode:self.surfaceNode];

    if( self.movingNode != nil )
    {
        [self handleMouseEventForNode:self.movingNode atPoint:positionInScene];
    }
}

- (void) mouseUp:(NSEvent *)theEvent
{
    self.movingNode = nil;
}



@end
