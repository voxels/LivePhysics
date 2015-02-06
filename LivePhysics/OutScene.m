//
//  OutScene.m
//  LivePhysics
//
//  Created by Voxels on 1/31/15.
//  Copyright (c) 2015 Noise Derived. All rights reserved.
//

#import "OutScene.h"
#import "OCVCaptureModel.h"
#import "CaptureTextureModel.h"
#import "Keypoint.h"


@interface OutScene ()

@property (strong) CaptureTextureModel *textureModel;
@property (strong) SKEffectNode *rootNode;
@property (strong) SKView *viewRef;
@property (strong) SKSpriteNode *cameraTextureSprite;
@property (strong) SKTexture *saveTexture;
@property (strong) SKSpriteNode *renderedNode;

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

@implementation OutScene

- (void) didMoveToView:(SKView *)view
{
    self.viewRef = view;
    [self setupRootNode];
    [self setupCameraTextureSprite];
}

- (void) setupRootNode
{
    self.rootNode = [[SKEffectNode alloc] init];
    self.rootNode.zPosition = 2.f;
}

- (void) setupCameraTextureSprite
{
    self.textureModel = [CaptureTextureModel sharedModel];
    self.cameraTextureSprite = [SKSpriteNode spriteNodeWithTexture:self.textureModel.cameraTexture size:CGSizeMake(1280, 720)];
//    self.cameraTextureSprite.size = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
//    self.cameraTextureSprite.position = CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height / 2.f);
    self.cameraTextureSprite.zPosition = 0;
    [self addChild:self.cameraTextureSprite];
    [self addChild:self.rootNode];
}

- (void) addKeyPoints:(NSArray *) keypoints
{
    NSLog(@"Keypoints: %lu", keypoints.count);
//    for( Keypoint *thisKeypoint in keypoints )
//    {
////        Keypoint *thisKeypoint = [keypoints firstObject];
//        SKShapeNode *keypointNode = [SKShapeNode shapeNodeWithCircleOfRadius:2.0];
//        keypointNode.fillColor = [SKColor colorWithRed:255.f/255.f green:62.f/255.f blue:181.f/255.f alpha:0.5];
//        keypointNode.lineWidth = 0;
//        keypointNode.position = CGPointMake( self.view.bounds.size.width - thisKeypoint.pt.x * 800.f/640.f, self.view.bounds.size.height - thisKeypoint.pt.y * 600.f/480.f);
//        keypointNode.zPosition = 3;
//        [self.rootNode addChild:keypointNode];
//    }
}


- (void) addContours:(NSArray *)contours
{
    NSLog(@"Contours: %lu", contours.count);
//    for( NSDictionary *thisContour in contours )
//    {
//        NSArray *points = thisContour[@"points"];
//        NSValue *firstPointValue = [points firstObject];
//        NSPoint firstPoint = firstPointValue.pointValue;
//        CGPoint scalePoint =  CGPointMake(self.view.bounds.size.width - firstPoint.x * 800.f/640.f, self.view.bounds.size.height - firstPoint.y * 600.f/480.f);
//        NSBezierPath *path = [NSBezierPath bezierPath];
//        [path moveToPoint:scalePoint];
//        for( int ii = 1; ii < points.count; ++ii )
//        {
//            NSValue *thisValue = [points objectAtIndex:ii];
//            CGPoint point = CGPointMake(self.view.bounds.size.width - thisValue.pointValue.x * 800.f/640.f, self.view.bounds.size.height -thisValue.pointValue.y * 600.f/480.f);
//            [path lineToPoint:point];
//        }
//        [path closePath];
//        
//        SKShapeNode *thisPath = [SKShapeNode shapeNodeWithPath:path.quartzPath];
//        thisPath.strokeColor = [SKColor colorWithRed:255.f/255.f green:170.f/255.f blue:77.f/255.f alpha:0.2];
//        thisPath.lineWidth = 1.f;
//        thisPath.zPosition = 5;
//        [self.rootNode addChild:thisPath];
//    }
}


- (void) didFinishUpdate
{
//    self.saveTexture = [self.view textureFromNode:self.rootNode];
//    self.renderedNode.texture = self.saveTexture;
//    if( !_renderedNode )
//    {
//        self.renderedNode = [[SKSpriteNode alloc] initWithTexture:self.saveTexture];
//        self.renderedNode.size = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
//        self.renderedNode.position = CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height / 2.f);
//        self.renderedNode.zPosition = 10;
//        [self addChild:self.renderedNode];
//    }
}
@end
