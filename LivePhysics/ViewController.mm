//
//  ViewController.m
//  LivePhysics
//
//  Created by Voxels on 1/27/15.
//  Copyright (c) 2015 Noise Derived. All rights reserved.
//

#import "ViewController.h"
#import <CoreVideo/CoreVideo.h>
#import <Accelerate/Accelerate.h>

#ifdef check
#undef check
#endif
#import "OCVSimpleBlobs.h"

#define clamp(a) (a>255?255:(a<0?0:a));

@interface ViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (assign, nonatomic) unsigned long lastTime;

@end

@implementation ViewController

cv::Mat* YUV2RGB(cv::Mat *src){
    cv::Mat *output = new cv::Mat(src->rows, src->cols, CV_8UC3);
    for(int i=0;i<output->rows;i++)
        for(int j=0;j<output->cols;j++){
            // from Wikipedia
            int c = src->data[i*src->cols*src->channels() + j*src->channels() + 0] - 16;
            int d = src->data[i*src->cols*src->channels() + j*src->channels() + 1] - 128;
            int e = src->data[i*src->cols*src->channels() + j*src->channels() + 2] - 128;
            
            output->data[i*src->cols*src->channels() + j*src->channels() + 0] = clamp((298*c+409*e+128)>>8);
            output->data[i*src->cols*src->channels() + j*src->channels() + 1] = clamp((298*c-100*d-208*e+128)>>8);
            output->data[i*src->cols*src->channels() + j*src->channels() + 2] = clamp((298*c+516*d+128)>>8);
        }
    
    return output;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setAcceptsTouchEvents:YES];

    [self setupAVSession];
    [session startRunning];
}

- (void) setupAVSession
{
    NSError *error;
    session = [AVCaptureSession new];
    [session setSessionPreset:AVCaptureSessionPreset640x480];
    
    for (AVCaptureDevice *device in [AVCaptureDevice devices]) {
        if ([device hasMediaType:AVMediaTypeVideo] || [device hasMediaType:AVMediaTypeMuxed]) {
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
            if (error) {
                NSLog(@"deviceInputWithDevice failed with error %@", [error localizedDescription]);
            }
            if ([session canAddInput:input] && [device.localizedName isEqualToString:@"USB2.0 Camera"])
            {
                NSLog(@"Session can add input");
                NSLog(@"%@", device.uniqueID);
                [session addInput:input];
                
            }
        }
    }
    
    AVCaptureVideoDataOutput *dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [dataOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    NSLog(@"%@", dataOutput.availableVideoCVPixelFormatTypes);
    [dataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
                                                             forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    
    [dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    [session addOutput:dataOutput];
    
    NSLog(@"inputs: %@", session.inputs);
    NSLog(@"outputs: %@", session.outputs);
    
    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [previewLayer setFrame:[self.captureView bounds]];
    [[previewLayer connection] setAutomaticallyAdjustsVideoMirroring:NO];
    [[previewLayer connection] setVideoMirrored:YES];
    
    CALayer *rootLayer = [self.captureView layer];
    [rootLayer setBackgroundColor:CGColorGetConstantColor(kCGColorBlack)];
    [rootLayer addSublayer:previewLayer];
}


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
// This might be faster with vImage, but there are no reference docs.

/*
 CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
 int bufferWidth = CVPixelBufferGetWidth(pixelBuffer);
 int bufferHeight = CVPixelBufferGetHeight(pixelBuffer);
 unsigned char *pixel = (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer);
 
 cv::Mat image = cv::Mat(bufferWidth,bufferHeight,CV_8UC4,pixel);
 //do any processing
 [self setDisplay_matrix:image];
 CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
 }
 */

- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    //convert from Core Media to Core Video
    [self toSingleChannel:sampleBuffer];
}

- (void) toSingleChannel:(CMSampleBufferRef)sampleBuffer
{
    CVImageBufferRef imageBuffer =  CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    size_t width = CVPixelBufferGetWidthOfPlane(imageBuffer, 0);
    
    size_t height = CVPixelBufferGetHeightOfPlane(imageBuffer, 0);
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
    
    // extract intensity channel directly
    
    Pixel_8 *lumaBuffer = (Pixel_8*)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    
    // render the luma buffer on the layer with CoreGraphics
    
    // (create color space, create graphics context, render buffer)
    
//    CGColorSpaceRef grayColorSpace = CGColorSpaceCreateDeviceGray();
//    CGContextRef context = CGBitmapContextCreate(lumaBuffer, width, height, 8, bytesPerRow, grayColorSpace, kCGImageAlphaNone);
    
    // delegate image processing to the delegate const vImage_Buffer image = {lumaBuffer, height, width, bytesPerRow};
    vImage_Buffer imagebuf = {lumaBuffer, height, width, bytesPerRow};
    cv::Mat grayImage((int)imagebuf.height, (int)imagebuf.width, CV_8U, imagebuf.data, imagebuf.rowBytes);
    
    detect(grayImage);
    
    CVPixelBufferUnlockBaseAddress( imageBuffer, 0 );
//    CGContextRelease(context);
}

- (void) captureOutput:(AVCaptureOutput *)captureOutput didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    NSLog(@"Did drop");
}


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
