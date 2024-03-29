//
//  OutScene.m
//  LivePhysics
//
//  Created by Voxels on 1/31/15.
//  Copyright (c) 2015 Noise Derived. All rights reserved.
//

#import "RenderScene.h"
#import "OCVCaptureModel.h"
#import "CaptureTextureModel.h"
#import "Keypoint.h"
#import "DeadEffectNode.h"
#import "Constants.h"

@interface RenderScene ()

@property (strong) CaptureTextureModel *textureModel;

@property (strong) SKSpriteNode *cameraTextureSprite;
@property (strong) SKEmitterNode *particleEmitterNode;
@property (strong) SKEmitterNode *trailsEmitterNode;

@property (strong) SKEffectNode *liveNode;
@property (strong) DeadEffectNode *deadNode;
@property (strong) SKEffectNode *renderNode;

@property (strong) SKEffectNode *contoursNode;
@property (strong) SKEffectNode *fillNode;
@property (strong) SKEffectNode *sparksNode;
@property (strong) SKEffectNode *fieldsNode;

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

@implementation RenderScene

- (void) didMoveToView:(SKView *)view
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePointsMoved:) name:@"movedPoints" object:nil];
    
    self.backgroundColor = [SKColor blackColor];
    
    [self setupEmitterNode];
    [self setupTrailsNode];

    [self setupLiveNode];
    [self setupCameraTextureSprite];
    [self setupDeadNode];
}

- (void) willMoveFromView:(SKView *)view
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setupLiveNode
{
    self.liveNode = [[SKEffectNode alloc] init];
    self.liveNode.zPosition = 0;
    
    self.contoursNode = [[SKEffectNode alloc] init];
    self.contoursNode.zPosition = 2;
    self.contoursNode.blendMode = SKBlendModeAdd;

    self.sparksNode = [[SKEffectNode alloc] init];
    self.sparksNode.zPosition = 3;
    self.sparksNode.blendMode = SKBlendModeAdd;
    
    self.fillNode = [[SKEffectNode alloc] init];
    self.fillNode.zPosition = 1;

    self.fieldsNode = [[SKEffectNode alloc] init];
    self.fieldsNode.zPosition = 6;
    self.fieldsNode.blendMode = SKBlendModeMultiply;
    
    [self.liveNode addChild:self.contoursNode];
    [self.liveNode addChild:self.fieldsNode];
    [self.liveNode addChild:self.fillNode];
    [self.liveNode addChild:self.sparksNode];
    [self addChild:self.liveNode];
    
    SKSpriteNode *coverNode = [[SKSpriteNode alloc] initWithColor:[SKColor blackColor] size:self.view.bounds.size];
    coverNode.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    coverNode.zPosition = 1;
//    [self addChild: coverNode];
}


- (void) setupDeadNode
{
    self.deadNode = [[DeadEffectNode alloc] initWithView:self.view];
    self.deadNode.zPosition = 2;
    [self addChild:self.deadNode];
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
    [self.liveNode addChild:self.cameraTextureSprite];
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
            if(contours.count > 0 )
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
                    
                    if( jj %2 == 0 )
                    {
                        SKSpriteNode *spriteNode = [self physicsSpriteWithPostion:point];
                        [self.sparksNode addChild:spriteNode];
                    }
                    else
                    {
                        SKEmitterNode *emitterNode = [self trailsNodeWithPosition:point];
                        [self.sparksNode addChild:emitterNode];
                    }
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
    
    double val = ((double)arc4random_uniform(12000)/1000);
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

    SKAction *waitAction = [SKAction waitForDuration:(double)arc4random_uniform(6000)/1000];
    SKAction *fadeAction = [SKAction fadeOutWithDuration:(double)arc4random_uniform(2000)/1000];
    
    SKAction *dieAction = [SKAction removeFromParent];
    SKAction *group = [SKAction sequence:@[waitAction, fadeAction, dieAction]];
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
    
    double val = ((double)arc4random_uniform(2000)/1000);
    SKAction *fadeAction = [SKAction fadeOutWithDuration:val];
    SKAction *dieAction = [SKAction removeFromParent];
    SKAction *group = [SKAction sequence:@[fadeAction, dieAction]];
    [node runAction:group];
    
    return node;
}

- (void) update:(NSTimeInterval)currentTime
{
    [self.deadNode updateSpriteTexture:[self.view textureFromNode:self.liveNode crop:self.view.frame]];
}

- (void) didFinishUpdate
{
    for(SKNode *node in self.sparksNode.children )
    {
        if( ![self.cameraTextureSprite containsPoint:node.position] )
        {
            [node removeFromParent];
        }
    }
    
}

- (void) handlePointsMoved:(NSNotification *)notification
{
    [self.deadNode updateTransformWithDictionary:notification.object];
}


@end