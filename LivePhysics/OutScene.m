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
#import "DeadEffectNode.h"


const NSInteger kOutSceneMaxCountours = 10;
const NSInteger kOutSceneMaxSparks = 20;
const NSInteger kOutSceneMaxFill = 15;
const NSInteger kOutSceneMaxFields = 15;

#define ADDPOINTS 1
#define ADDCONTOURS 1

@interface OutScene ()

@property (strong) CaptureTextureModel *textureModel;

@property (strong) SKSpriteNode *cameraTextureSprite;
@property (strong) SKEmitterNode *particleEmitterNode;
@property (strong) SKEmitterNode *trailsEmitterNode;

@property (strong) SKEffectNode *liveNode;
@property (strong) SKEffectNode *deadNode;
@property (strong) CIFilter *transformFilter;

@property (strong) SKEffectNode *contoursNode;
@property (strong) SKEffectNode *sparksNode;
@property (strong) SKEffectNode *fillNode;
@property (strong) SKEffectNode *fieldsNode;

@property (strong) SKTexture *deadContoursTexture;
@property (strong) SKSpriteNode *deadContoursSpriteNode;
@property (strong) SKEffectNode *deadContoursEffectNode;

@property (strong) DeadEffectNode *contoursDeadNode;

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
    self.backgroundColor = [SKColor blackColor];
    
    [self setupCameraTextureSprite];
    [self setupEmitterNode];
    [self setupTrailsNode];

    [self setupLiveNode];
    [self setupDeadNode];
    
    [self addChild:self.liveNode];
}



- (void) setupLiveNode
{
    self.liveNode = [[SKEffectNode alloc] init];
    self.liveNode.zPosition = 1;
    
    self.contoursNode = [[SKEffectNode alloc] init];
    self.contoursNode.zPosition = 1.f;
    self.contoursNode.blendMode = SKBlendModeAdd;

    self.sparksNode = [[SKEffectNode alloc] init];
    self.sparksNode.zPosition = 2.f;
    
    self.fillNode = [[SKEffectNode alloc] init];
    self.fillNode.zPosition = 1.f;

    self.fieldsNode = [[SKEffectNode alloc] init];
    self.fieldsNode.zPosition = 6;
    self.fieldsNode.blendMode = SKBlendModeMultiply;
    
    [self.liveNode addChild:self.contoursNode];
    [self.liveNode addChild:self.fieldsNode];
    [self.liveNode addChild:self.fillNode];
    [self.liveNode addChild:self.sparksNode];
    
}

- (void) setupDeadNode
{
    self.deadNode = [[SKEffectNode alloc] init];
    self.deadNode.zPosition = 10;

    CIFilter *renderedFilter = [CIFilter filterWithName:@"CIColorInvert"];
    self.contoursDeadNode = [[DeadEffectNode alloc] initWithView:self.view];
    self.contoursDeadNode.filter = renderedFilter;
    self.contoursDeadNode.zPosition = 10;
    
    [self addChild:self.contoursDeadNode];
}


- (void) setupEmitterNode
{
    NSString *magicPath = [[NSBundle mainBundle] pathForResource:@"MagicParticle" ofType:@"sks"];
    self.particleEmitterNode = [NSKeyedUnarchiver unarchiveObjectWithFile:magicPath];
}

- (void) setupTrailsNode
{
    NSString *magicPath = [[NSBundle mainBundle] pathForResource:@"BokehParticle" ofType:@"sks"];
    self.trailsEmitterNode = [NSKeyedUnarchiver unarchiveObjectWithFile:magicPath];
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
        int availableCount = kOutSceneMaxFill - (int) self.fillNode.children.count;
        if( availableCount > 0 )
        {
            for( int ii = 0; ii < availableCount; ++ii )
            {
                int randomPointIndex = arc4random_uniform((int)keypoints.count);
                if( randomPointIndex < keypoints.count && keypoints.count > 0 )
                {
                    Keypoint *thisKeypoint = [keypoints objectAtIndex:randomPointIndex];
                    SKEmitterNode *shapeNode = [self markerSpriteWithKeypoint:thisKeypoint];
                    [self.fillNode addChild:shapeNode];
                }
            }
        }
    }
}


- (void) addContours:(NSArray *)contours
{
//    [self.contoursNode removeAllChildren];
    if( ADDCONTOURS )
    {
        [self addContourLines:contours];
        [self addCornerPoints:contours];
    }
}


- (void) addContourLines:(NSArray *)contours
{
    int availableCount = kOutSceneMaxCountours - (int)self.contoursNode.children.count;
    
    if( availableCount > 0  )
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
                float rX = (float)arc4random_uniform(10) - 5.f;
                float rY = (float)arc4random_uniform(10) - 5.f;
                CGPoint point = CGPointMake((self.view.bounds.size.width - thisValue.pointValue.x)*2.f - 1280.f + rX, (self.view.bounds.size.height - thisValue.pointValue.y)*2.f - 800.f + rY);
                [path lineToPoint:point];
            }
            
            [path closePath];
            
            SKShapeNode *thisPath = [SKShapeNode shapeNodeWithPath:path.quartzPath];

//            SKPhysicsBody *body = [SKPhysicsBody bodyWithEdgeChainFromPath:path.quartzPath];
//            thisPath.physicsBody = body;
            thisPath.strokeColor = [SKColor colorWithWhite:1.f alpha:0.9f];
            thisPath.lineWidth = 2.f;
            thisPath.glowWidth = 3.f;
            thisPath.zPosition = 5;
            thisPath.lineCap = kCGLineCapRound;
            thisPath.lineJoin = kCGLineJoinRound;
            
            double val = ((double)arc4random_uniform(8000)/1000);
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
    int availableCount = kOutSceneMaxSparks - (int)self.sparksNode.children.count;

    if( availableCount > 0 )
    {
        for( int ii = 0; ii < availableCount; ++ii )
        {
            int randomPointIndex = arc4random_uniform((int)contours.count);
            if( randomPointIndex < contours.count && contours.count != 0 )
            {
                NSDictionary *thisContour = [contours objectAtIndex:randomPointIndex];
                NSArray *points = thisContour[@"points"];
                
                if( kOutSceneMaxFields - (int)self.fieldsNode.children.count > 0 )
                {
                    NSValue *firstValue = [points firstObject];
                    SKFieldNode *fieldNode = [self noiseNodeWithValue:firstValue];
                    [self.fieldsNode addChild:fieldNode];
                }
                
                for( int jj = 1; jj < points.count-1; ++jj )
                {
                    NSValue *thisValue = [points objectAtIndex:jj];
                    CGPoint point = CGPointMake((self.view.bounds.size.width - thisValue.pointValue.x)*2.f - 1280.f, (self.view.bounds.size.height - thisValue.pointValue.y)*2.f - 800.f);
                    
                    SKSpriteNode *spriteNode = [self physicsSpriteWithPostion:point];
//                    SKEmitterNode *emitterNode = [self trailsNodeWithPosition:point];
                    [self.sparksNode addChild:spriteNode];
                }
                
                if( kOutSceneMaxFields - (int)self.fieldsNode.children.count > 0 )
                {
                    NSValue *firstValue = [points lastObject];
                    SKFieldNode *fieldNode = [self turbulenceNodeWithValue:firstValue];
                    [self.fieldsNode addChild:fieldNode];
                }
            }
        }
    }
}



- (SKSpriteNode *) physicsSpriteWithPostion:(CGPoint)point
{
    SKSpriteNode *spriteNode = [SKSpriteNode spriteNodeWithImageNamed:@"bokeh"];
    
    spriteNode.position = CGPointMake(point.x + arc4random_uniform(10) - 5, point.y + arc4random_uniform(10) - 5);
    spriteNode.zPosition = 3;
    spriteNode.size = CGSizeMake(4.f, 4.f);
    spriteNode.color = [SKColor colorWithRed:97.0/255.0 green:0.f blue:159.f/255.f alpha:1.f];
    spriteNode.colorBlendFactor = 0.6;
    spriteNode.blendMode = SKBlendModeAdd;
    
    SKPhysicsBody *body = [SKPhysicsBody bodyWithCircleOfRadius:1];
    spriteNode.physicsBody = body;
    
    double val = ((double)arc4random_uniform(500)/1000);
    double rot = arc4random_uniform(5);
    SKAction *fadeAction = [SKAction fadeOutWithDuration:val];
    SKAction *growAction = [SKAction scaleBy:4.0 duration:val];
    SKAction *rotateAction = [SKAction rotateByAngle:M_PI * rot duration:val];
    SKAction *buildAction = [SKAction group:@[fadeAction, growAction, rotateAction]];
    SKAction *dieAction = [SKAction removeFromParent];
    SKAction *group = [SKAction sequence:@[buildAction, dieAction]];
    [spriteNode runAction:group];
    return spriteNode;
}


- (SKEmitterNode *)trailsNodeWithPosition:(CGPoint)point
{
    SKEmitterNode *node = [self.trailsEmitterNode copy];
    node.position = CGPointMake(point.x + arc4random_uniform(10) - 5, point.y + arc4random_uniform(10) - 5);
    node.zPosition = 3;

    SKPhysicsBody *body = [SKPhysicsBody bodyWithCircleOfRadius:3];
    node.physicsBody = body;

    double val = ((double)arc4random_uniform(6000)/1000);
    SKAction *fadeAction = [SKAction fadeOutWithDuration:val];
    SKAction *dieAction = [SKAction removeFromParent];
    SKAction *group = [SKAction sequence:@[fadeAction, dieAction]];
    [node runAction:group];
    return node;
}


- (SKEmitterNode *)markerSpriteWithKeypoint:(Keypoint *)keypoint
{
//    SKShapeNode *node = [SKShapeNode shapeNodeWithCircleOfRadius:keypoint.size];
    SKEmitterNode *node = [self.particleEmitterNode copy];
    CGPoint point = CGPointMake((self.view.bounds.size.width - keypoint.pt.x)*2.f - 1280.f, (self.view.bounds.size.height - keypoint.pt.y)*2.f - 800.f);

    node.position = point;
    double val = ((double)arc4random_uniform(5000)/1000);
    SKAction *fadeAction = [SKAction fadeOutWithDuration:val];
    SKAction *dieAction = [SKAction removeFromParent];
    SKAction *group = [SKAction sequence:@[fadeAction, dieAction]];
    [node runAction:group];
    return node;
}



- (SKFieldNode *) fieldNodeWithKeypoint:(Keypoint *)keypoint
{
    SKFieldNode *node = [SKFieldNode radialGravityField];
    node.region = [[SKRegion alloc] initWithRadius:50.f];
    CGPoint point = CGPointMake((self.view.bounds.size.width - keypoint.pt.x)*2.f - 1280.f, (self.view.bounds.size.height - keypoint.pt.y)*2.f - 800.f);
    node.position = point;
    
    double val = ((double)arc4random_uniform(2000)/1000);
    SKAction *fadeAction = [SKAction fadeOutWithDuration:val];
    SKAction *dieAction = [SKAction removeFromParent];
    SKAction *group = [SKAction sequence:@[fadeAction, dieAction]];
    [node runAction:group];

    return node;
}

- (SKFieldNode *)noiseNodeWithValue:(NSValue *)thisValue
{
    SKFieldNode *node = [SKFieldNode noiseFieldWithSmoothness:1.0 animationSpeed:1.0];
    node.region = [[SKRegion alloc] initWithRadius:20.f];
    CGPoint point = CGPointMake((self.view.bounds.size.width - thisValue.pointValue.x)*2.f - 1280.f, (self.view.bounds.size.height - thisValue.pointValue.y)*2.f - 800.f);
    node.position = point;
    node.strength = 0.05;
    
    double val = ((double)arc4random_uniform(1000)/1000);
    SKAction *fadeAction = [SKAction fadeOutWithDuration:val];
    SKAction *dieAction = [SKAction removeFromParent];
    SKAction *group = [SKAction sequence:@[fadeAction, dieAction]];
    [node runAction:group];
    
    return node;
}

- (SKFieldNode *)turbulenceNodeWithValue:(NSValue *)thisValue
{
    SKFieldNode *node = [SKFieldNode turbulenceFieldWithSmoothness:0.5 animationSpeed:2.0];
//    SKFieldNode *node = [SKFieldNode dragField];
    node.region = [[SKRegion alloc] initWithRadius:200.f];
    CGPoint point = CGPointMake((self.view.bounds.size.width - thisValue.pointValue.x)*2.f - 1280.f, (self.view.bounds.size.height - thisValue.pointValue.y)*2.f - 800.f);
    node.position = point;
    
    double val = ((double)arc4random_uniform(8000)/1000);
    SKAction *fadeAction = [SKAction fadeOutWithDuration:val];
    SKAction *dieAction = [SKAction removeFromParent];
    SKAction *group = [SKAction sequence:@[fadeAction, dieAction]];
    [node runAction:group];
    
    return node;
}

- (void) update:(NSTimeInterval)currentTime
{
    [self updateDeadContours];

}


- (void) updateDeadContours
{
    CGRect rect = self.contoursNode.calculateAccumulatedFrame;
    [self.contoursDeadNode updateSpriteTexture:[self.view textureFromNode:self.contoursNode] forRect:rect];
}

- (void) didFinishUpdate
{
    
}
@end
