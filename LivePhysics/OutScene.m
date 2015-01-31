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

@interface OutScene ()

@property (strong) CaptureTextureModel *textureModel;
@property (strong) SKEffectNode *rootNode;
@property (strong) SKView *viewRef;
@property (strong) SKSpriteNode *cameraTextureSprite;
@property (strong) SKTexture *saveTexture;
@property (strong) SKSpriteNode *renderedNode;

@end


@implementation OutScene

- (void) didMoveToView:(SKView *)view
{
    self.viewRef = view;
//    [self setupRootNode];
    [self setupCameraTextureSprite];
}

- (void) setupRootNode
{
    self.rootNode = [[SKEffectNode alloc] init];
    [self.rootNode setShouldEnableEffects:NO];
    [self.rootNode setShouldRasterize:YES];
}

- (void) setupCameraTextureSprite
{
    self.textureModel = [CaptureTextureModel sharedModel];
    self.cameraTextureSprite = [SKSpriteNode spriteNodeWithTexture:self.textureModel.cameraTexture size:self.viewRef.bounds.size];

    self.cameraTextureSprite.size = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
    self.cameraTextureSprite.position = CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height / 2.f);

    [self addChild:self.cameraTextureSprite];
//    [self.rootNode addChild:self.cameraTextureSprite];
}

- (void) addKeyPoints:(NSArray *) keypoints
{
//    NSLog(@"Keypoints: %lu", keypoints.count);
}


- (void) addContours:(NSArray *)contours
{
//    NSLog(@"Contours: %lu", contours.count);
}


- (void) didFinishUpdate
{
//    self.saveTexture = [self.view textureFromNode:self.rootNode];
//    self.renderedNode.texture = self.saveTexture;
//    if( !_renderedNode )
//    {
//        NSLog(@"adding root node");
//        self.renderedNode = [[SKSpriteNode alloc] initWithTexture:self.saveTexture];
//        self.renderedNode.size = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
//        self.renderedNode.position = CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height / 2.f);
//        [self addChild:self.renderedNode];
//    }
}
@end
