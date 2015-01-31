//
//  ViewController.h
//  LivePhysics
//
//  Created by Voxels on 1/27/15.
//  Copyright (c) 2015 Noise Derived. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>


@interface ViewController : NSViewController
{
    AVCaptureSession *session;
    AVCaptureVideoPreviewLayer *previewLayer;
}

@property (weak) IBOutlet NSView *captureView;

@end

