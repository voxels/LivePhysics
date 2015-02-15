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
@property SKShapeNode *outputShapeNode;
@property NSMutableDictionary *outputShapePoints;
@property SKNode *movingNode;

@property CGPoint lastLocation;

@end


@implementation NSBezierPath (BezierPathQuartzUtilities)
// This method works only in OS X v10.2 and later.
- (CGPathRef)quartzPath
{
    int i, numElements;
    
    // Need to begin a path here.
    CGPathRef           immutablePath = NULL;
    
    // Then draw the path elements.
    numElements = [self elementCount];
    if (numElements > 0)
    {
        CGMutablePathRef    path = CGPathCreateMutable();
        NSPoint             points[3];
        BOOL                didClosePath = YES;
        
        for (i = 0; i < numElements; i++)
        {
            switch ([self elementAtIndex:i associatedPoints:points])
            {
                case NSMoveToBezierPathElement:
                    CGPathMoveToPoint(path, NULL, points[0].x, points[0].y);
                    break;
                    
                case NSLineToBezierPathElement:
                    CGPathAddLineToPoint(path, NULL, points[0].x, points[0].y);
                    didClosePath = NO;
                    break;
                    
                case NSCurveToBezierPathElement:
                    CGPathAddCurveToPoint(path, NULL, points[0].x, points[0].y,
                                          points[1].x, points[1].y,
                                          points[2].x, points[2].y);
                    didClosePath = NO;
                    break;
                    
                case NSClosePathBezierPathElement:
                    CGPathCloseSubpath(path);
                    didClosePath = YES;
                    break;
            }
        }
        
        // Be sure the path is closed or Quartz may not do valid hit detection.
        if (!didClosePath)
            CGPathCloseSubpath(path);
        
        immutablePath = CGPathCreateCopy(path);
        CGPathRelease(path);
    }
    
    return immutablePath;
}
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

- (NSDictionary *)initialConditions
{
    CGPoint topLeftPoint = CGPointMake(CGRectGetMidX(self.view.bounds) - CGRectGetWidth(self.view.bounds) / 10.f, CGRectGetMidY(self.view.bounds) + CGRectGetHeight(self.view.bounds) / 10.f);
    CGPoint topRightPoint = CGPointMake(CGRectGetMidX(self.view.bounds) + CGRectGetWidth(self.view.bounds) / 10.f, CGRectGetMidY(self.view.bounds) + CGRectGetHeight(self.view.bounds) / 10.f);
    
    CGPoint bottomRightPoint = CGPointMake(CGRectGetMidX(self.view.bounds) + CGRectGetWidth(self.view.bounds) / 10.f, CGRectGetMidY(self.view.bounds) - CGRectGetHeight(self.view.bounds) / 10.f);
    
    CGPoint bottomLeftPoint = CGPointMake(CGRectGetMidX(self.view.bounds) - CGRectGetWidth(self.view.bounds) / 10.f, CGRectGetMidY(self.view.bounds) - CGRectGetHeight(self.view.bounds) / 10.f);
    
    return @{
             @"topLeftPoint" : [NSValue valueWithPoint:topLeftPoint],
             @"topRightPoint" : [NSValue valueWithPoint:topRightPoint],
             @"bottomRightPoint" : [NSValue valueWithPoint:bottomRightPoint],
             @"bottomLeftPoint" : [NSValue valueWithPoint:bottomLeftPoint]
             };
}

- (void) setupSurface
{
    self.surfaceNode = [[SKNode alloc] init];
    self.surfaceNode.name = @"surface";
    [self.rootNode addChild:self.surfaceNode];
    
    NSDictionary *positions = [self initialConditions];
    NSValue *topLeftPoint = positions[@"topLeftPoint"];
    NSValue *topRightPoint = positions[@"topRightPoint"];
    NSValue *bottomLeftPoint = positions[@"bottomLeftPoint"];
    NSValue *bottomRightPoint = positions[@"bottomRightPoint"];
    
    self.topLeftHandle = [SKShapeNode shapeNodeWithCircleOfRadius:kHandleSize];
    self.topLeftHandle.name = @"topLeftPoint";
    self.topLeftHandle.position = topLeftPoint.pointValue;
    self.topLeftHandle.fillColor = [SKColor whiteColor];
    self.topLeftHandle.zPosition = 1;
    [self.surfaceNode addChild:self.topLeftHandle];
    
    self.topRightHandle = [SKShapeNode shapeNodeWithCircleOfRadius:kHandleSize];
    self.topRightHandle.name = @"topRightPoint";
    self.topRightHandle.position = topRightPoint.pointValue;
    self.topRightHandle.fillColor = [SKColor whiteColor];
    self.topRightHandle.zPosition = 1;
    [self.surfaceNode addChild:self.topRightHandle];

    self.bottomRightHandle = [SKShapeNode shapeNodeWithCircleOfRadius:kHandleSize];
    self.bottomRightHandle.name = @"bottomRightPoint";
    self.bottomRightHandle.position = bottomRightPoint.pointValue;
    self.bottomRightHandle.fillColor = [SKColor whiteColor];
    self.bottomRightHandle.zPosition = 1;
    [self.surfaceNode addChild:self.bottomRightHandle];

    self.bottomLeftHandle = [SKShapeNode shapeNodeWithCircleOfRadius:kHandleSize];
    self.bottomLeftHandle.name = @"bottomLeftPoint";
    self.bottomLeftHandle.position = bottomLeftPoint.pointValue;
    self.bottomLeftHandle.fillColor = [SKColor whiteColor];
    self.bottomLeftHandle.zPosition = 1;
    [self.surfaceNode addChild:self.bottomLeftHandle];
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:topLeftPoint.pointValue];
    [path lineToPoint:topRightPoint.pointValue];
    [path lineToPoint:bottomRightPoint.pointValue];
    [path lineToPoint:bottomLeftPoint.pointValue];
    [path closePath];
    
    self.outputShapeNode = [SKShapeNode shapeNodeWithPath:[self pathWithDictionary:positions].quartzPath];
    self.outputShapeNode.fillColor = [SKColor darkGrayColor];
    self.outputShapeNode.zPosition = 0;
    [self.surfaceNode addChild:self.outputShapeNode];
    
    self.outputShapePoints = positions.mutableCopy;
}


- (NSBezierPath *) pathWithDictionary:(NSMutableDictionary *)dict
{
    NSValue *topLeftPoint = dict[@"topLeftPoint"];
    NSValue *topRightPoint = dict[@"topRightPoint"];
    NSValue *bottomLeftPoint = dict[@"bottomLeftPoint"];
    NSValue *bottomRightPoint = dict[@"bottomRightPoint"];

    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:topLeftPoint.pointValue];
    [path lineToPoint:topRightPoint.pointValue];
    [path lineToPoint:bottomRightPoint.pointValue];
    [path lineToPoint:bottomLeftPoint.pointValue];
    [path closePath];

    return path;
}

- (void) handleMouseEventForNode:(SKNode *)node atPoint:(CGPoint)location
{
    node.position = location;
    [self.outputShapePoints setValue:[NSValue valueWithPoint:location] forKey:node.name];
    self.outputShapeNode.path = [self pathWithDictionary:self.outputShapePoints].quartzPath;
    
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




