//
//  ViewController.m
//  LivePhysics
//
//  Created by Voxels on 1/27/15.
//  Copyright (c) 2015 Noise Derived. All rights reserved.
//

#import "ViewController.h"
#import <CoreVideo/CoreVideo.h>


@interface ViewController () 

@property (assign, nonatomic) unsigned long lastTime;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setAcceptsTouchEvents:YES];
    //    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    //    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    //    [previewLayer setFrame:[self.captureView bounds]];
    //    [[previewLayer connection] setAutomaticallyAdjustsVideoMirroring:NO];
    //    [[previewLayer connection] setVideoMirrored:YES];
    //
    //    CALayer *rootLayer = [self.captureView layer];
    //    [rootLayer setBackgroundColor:CGColorGetConstantColor(kCGColorBlack)];
    //    [rootLayer addSublayer:previewLayer];
}


#pragma mark - View controller
- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void) mouseDown:(NSEvent *)theEvent
{
    [super mouseDown:theEvent];
    
    NSLog(@"Mouse Down" );
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}



@end
