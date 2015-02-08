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

const NSInteger kOutSceneMaxCountours = 150;
const NSInteger kOutSceneMaxCorners = 100;
const NSInteger kOutSceneMaxKeypoints = 300;

#define ADDPOINTS 1
#define ADDCONTOURS 1

@interface OutScene ()

@property (strong) CaptureTextureModel *textureModel;
@property (strong) SKEffectNode *rootNode;
@property (strong) SKEffectNode *contoursNode;
@property (strong) SKEffectNode *cornersNode;
@property (strong) SKEffectNode *keypointsNode;
@property (strong) SKShapeNode *warpNode;
@property (strong) SKView *viewRef;
@property (strong) SKSpriteNode *cameraTextureSprite;
@property (strong) SKTexture *saveTexture;
@property (strong) SKSpriteNode *renderedNode;
@property (strong) SKEmitterNode *particleEmitterNode;

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
    [self setupEmitterNode];
    [self setupCameraTextureSprite];
    [self addChild:self.rootNode];
}

- (void) setupRootNode
{
    self.rootNode = [[SKEffectNode alloc] init];
    self.rootNode.zPosition = 2.f;
    
    self.contoursNode = [[SKEffectNode alloc] init];
    self.contoursNode.zPosition = 1.f;

    self.cornersNode = [[SKEffectNode alloc] init];
    self.cornersNode.zPosition = 2.f;
    
    self.keypointsNode = [[SKEffectNode alloc] init];
    self.keypointsNode.zPosition = 1.f;

    self.warpNode = [[SKShapeNode alloc] init];
//    self.warpNode.path = [self pathForWarp];
    self.warpNode.fillColor = [SKColor redColor];
    self.warpNode.zPosition = 6;
    self.warpNode.fillTexture = [SKTexture textureWithImageNamed:@"screenshot"];
    
    [self.rootNode addChild:self.contoursNode];
    [self.rootNode addChild:self.cornersNode];
    [self.rootNode addChild:self.keypointsNode];
    [self.rootNode addChild:self.warpNode];
}

- (CGMutablePathRef) pathForWarp
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 200, 200);
    CGPathAddLineToPoint(path, NULL, 250, 250);
    CGPathAddLineToPoint(path, NULL, 200, 300);
    CGPathAddLineToPoint(path, NULL, 150, 250);
    CGPathAddLineToPoint(path, NULL, 200, 200);
    
    return path;
}

- (void) setupEmitterNode
{
    NSString *magicPath = [[NSBundle mainBundle] pathForResource:@"MagicParticle" ofType:@"sks"];
    self.particleEmitterNode = [NSKeyedUnarchiver unarchiveObjectWithFile:magicPath];
}

- (void) setupCameraTextureSprite
{
    self.textureModel = [CaptureTextureModel sharedModel];
    self.cameraTextureSprite = [SKSpriteNode spriteNodeWithTexture:self.textureModel.cameraTexture size:CGSizeMake(1920, 1080)];
    self.cameraTextureSprite.size = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
    self.cameraTextureSprite.position = CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height / 2.f);
    self.cameraTextureSprite.zPosition = 0;
    [self addChild:self.cameraTextureSprite];
}

- (void) addKeyPoints:(NSArray *) keypoints
{
    if( ADDPOINTS )
    {
        int availableCount = kOutSceneMaxKeypoints - (int) self.keypointsNode.children.count;
        if( availableCount > 0 )
        {
            for( int ii = 0; ii < availableCount; ++ii )
            {
                int randomPointIndex = arc4random_uniform((int)keypoints.count);
                Keypoint *thisKeypoint = [keypoints objectAtIndex:randomPointIndex];
                SKSpriteNode *keypointNode = [SKSpriteNode spriteNodeWithImageNamed:@"spark"];
                keypointNode.position = CGPointMake( self.view.bounds.size.width - thisKeypoint.pt.x, self.view.bounds.size.height - thisKeypoint.pt.y);
                keypointNode.zPosition = 3;
                keypointNode.size = CGSizeMake(10.f, 10.f);
                SKPhysicsBody *body = [SKPhysicsBody bodyWithCircleOfRadius:5];
                keypointNode.physicsBody = body;
                
                double val = ((double)arc4random_uniform(2000)/1000);
                SKAction *fadeAction = [SKAction fadeOutWithDuration:val];
                SKAction *dieAction = [SKAction removeFromParent];
                SKAction *group = [SKAction sequence:@[fadeAction, dieAction]];

                [self.keypointsNode addChild:keypointNode];
                [keypointNode runAction:group];
            }
        }
    }
}


- (void) addContours:(NSArray *)contours
{
//    [self.contoursNode removeAllChildren];
    if( ADDCONTOURS )
    {
//        [self addContourLines:contours];
        [self addCornerPoints:contours];
    }
}


- (void) addContourLines:(NSArray *)contours
{
    int availableCount = kOutSceneMaxCountours - (int)self.contoursNode.children.count;
    
    if( availableCount > 0 )
    {
        for( int ii = 0; ii < availableCount; ++ii )
        {
            int randomPointIndex = arc4random_uniform((int)contours.count);

            NSDictionary *thisContour = [contours objectAtIndex:randomPointIndex];
            NSArray *points = thisContour[@"points"];
            
            NSValue *firstPointValue = [points firstObject];
            NSPoint firstPoint = firstPointValue.pointValue;
            CGPoint scalePoint =  CGPointMake((self.view.bounds.size.width - firstPoint.x) * 2.f - 1280.f, (self.view.bounds.size.height - firstPoint.y)*2.f - 800.f);
            NSBezierPath *path = [NSBezierPath bezierPath];
            [path moveToPoint:scalePoint];
            
            for( int ii = 1; ii < points.count; ++ii )
            {
                NSValue *thisValue = [points objectAtIndex:ii];
                CGPoint point = CGPointMake((self.view.bounds.size.width - thisValue.pointValue.x)*2.f - 1280.f, (self.view.bounds.size.height - thisValue.pointValue.y)*2.f - 800.f);
                [path lineToPoint:point];
            }
            
            [path closePath];
            
            SKShapeNode *thisPath = [SKShapeNode shapeNodeWithPath:path.quartzPath];
//            SKPhysicsBody *body = [SKPhysicsBody bodyWithEdgeChainFromPath:path.quartzPath];
//            thisPath.physicsBody = body;
            
            thisPath.strokeColor = [SKColor colorWithRed:255.f/255.f green:255.f/255.f blue:255.f/255.f alpha:0.7];
            thisPath.lineWidth = 5.f;
            thisPath.zPosition = 5;
            
            double val = ((double)arc4random_uniform(3000)/1000);
            SKAction *fadeAction = [SKAction fadeOutWithDuration:val];
            SKAction *dieAction = [SKAction removeFromParent];
            SKAction *group = [SKAction sequence:@[fadeAction, dieAction]];
            
            [self.contoursNode addChild:thisPath];
            [thisPath runAction:group];
        }
    }
}


- (void) addCornerPoints:(NSArray *)contours
{
    int availableCount = kOutSceneMaxCorners - (int)self.cornersNode.children.count;

    if( availableCount > 0 )
    {
        for( int ii = 0; ii < availableCount; ++ii )
        {
            int randomPointIndex = arc4random_uniform((int)contours.count);

            NSDictionary *thisContour = [contours objectAtIndex:randomPointIndex];
            NSArray *points = thisContour[@"points"];
            
            for( int jj = 0; jj < points.count; ++jj )
            {
                NSValue *thisValue = [points objectAtIndex:jj];
                CGPoint point = CGPointMake((self.view.bounds.size.width - thisValue.pointValue.x)*2.f - 1280.f, (self.view.bounds.size.height - thisValue.pointValue.y)*2.f - 800.f);
                SKShapeNode *thisPath = [SKShapeNode shapeNodeWithCircleOfRadius:2.0];
                SKPhysicsBody *body = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(1, 1)];
                body.dynamic = NO;
                thisPath.physicsBody = body;
                
                thisPath.strokeColor = [SKColor colorWithRed:255.f/255.f green:0.f/255.f blue:0.f/255.f alpha:0.7];
                thisPath.lineWidth = 5.f;
                thisPath.zPosition = 5;
                thisPath.position = point;
                
                double val = ((double)arc4random_uniform(2000)/1000);
                SKAction *fadeAction = [SKAction fadeOutWithDuration:val];
                SKAction *dieAction = [SKAction removeFromParent];
                SKAction *group = [SKAction sequence:@[fadeAction, dieAction]];
                
                [self.cornersNode addChild:thisPath];
                [thisPath runAction:group];
            }
        }
    }
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
