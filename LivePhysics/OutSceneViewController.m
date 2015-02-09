//
//  OutSceneViewController.m
//  LivePhysics
//
//  Created by Voxels on 1/31/15.
//  Copyright (c) 2015 Noise Derived. All rights reserved.
//

#import "OutSceneViewController.h"
#import "OutScene.h"
#import "OCVCaptureModel.h"

@interface OutSceneViewController () <OCVCaptureModelDelegate>

@property (strong, nonatomic) OutScene *outScene;
@property (strong, nonatomic) OCVCaptureModel *captureModel;

@end

@implementation OutSceneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.captureModel = [OCVCaptureModel sharedModel];
    self.captureModel.delegate = self;

    if(!_outScene )
    {
        self.outScene = [[OutScene alloc] initWithSize:CGSizeMake(1280, 800)];
        self.outScene.physicsWorld.gravity = CGVectorMake(0.f, 0.1f);
//        self.outScene.scaleMode = SKSceneScaleModeAspectFit;
    }
    
//    self.outSceneView.ignoresSiblingOrder = YES;
    self.outSceneView.showsFPS = YES;
    self.outSceneView.showsNodeCount = YES;
    [self.outSceneView presentScene:self.outScene];
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
