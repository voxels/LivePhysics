//
//  OutSceneViewController.m
//  LivePhysics
//
//  Created by Voxels on 1/31/15.
//  Copyright (c) 2015 Noise Derived. All rights reserved.
//

#import "RenderSceneViewController.h"
#import "RenderScene.h"
#import "OCVCaptureModel.h"

@interface RenderSceneViewController () <OCVCaptureModelDelegate>

@property (strong, nonatomic) RenderScene *outScene;
@property (strong, nonatomic) OCVCaptureModel *captureModel;

@end

@implementation RenderSceneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.captureModel = [OCVCaptureModel sharedModel];
    self.captureModel.delegate = self;

    if(!_outScene )
    {
        self.outScene = [[RenderScene alloc] initWithSize:CGSizeMake(1280, 800)];
        self.outScene.physicsWorld.gravity = CGVectorMake(0.f, 0.1f);
//        self.outScene.scaleMode = SKSceneScaleModeAspectFit;
    }
    
//    self.outSceneView.ignoresSiblingOrder = YES;
    self.renderSceneView.showsFPS = YES;
    self.renderSceneView.showsNodeCount = YES;
    [self.renderSceneView presentScene:self.outScene];
}


#pragma mark - OCVCaptureDelegate

- (void) captureModelDidFindKeypoints:(NSArray *)keypoints
{
//    self.outScene.physicsWorld.gravity;
    [self.outScene addKeyPoints:keypoints];
    
}

- (void) captureModelDidFindContours:(NSArray *)contours
{
    [self.outScene addContours:contours];
}

@end
