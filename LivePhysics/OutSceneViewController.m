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

@interface OutSceneViewController ()

@property (strong, nonatomic) OutScene *outScene;
@property (strong, nonatomic) OCVCaptureModel *captureModel;

@end

@implementation OutSceneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if(!_outScene )
    {
        self.outScene = [[OutScene alloc] initWithSize:CGSizeMake(800, 600)];
    }
    [self setupCamTexture];
    
    self.captureModel = [OCVCaptureModel sharedModel];
}



- (void) setupCamTexture
{
    NSLog(@"Setup camera texture");
    self.outScene.cameraTexture = [[SKMutableTexture alloc] initWithSize:CGSizeMake(kDetectSessionWidth, kDetectSessionHeight) pixelFormat:kCVPixelFormatType_32RGBA];
}



@end
