//
//  OCVCaptureModel.h
//  LivePhysics
//
//  Created by Voxels on 1/31/15.
//  Copyright (c) 2015 Noise Derived. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

extern const CGFloat kDetectSessionWidth;
extern const CGFloat kDetectSessionHeight;

@protocol OCVCaptureModelDelegate <NSObject>

- (void) captureModelDidFindKeypoints:(NSArray *)keypoints;
- (void) captureModelDidFindContours:(NSArray *)contours;
- (void) setCameraTexture;

@end

@interface OCVCaptureModel : NSObject
{
    AVCaptureSession *session;
    AVCaptureVideoPreviewLayer *previewLayer;
}

@property (weak) id<OCVCaptureModelDelegate>delegate;

+ (instancetype) sharedModel;

@end
