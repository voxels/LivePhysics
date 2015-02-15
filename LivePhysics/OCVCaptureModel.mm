//
//  OCVCaptureModel.m
//  LivePhysics
//
//  Created by Voxels on 1/31/15.
//  Copyright (c) 2015 Noise Derived. All rights reserved.
//

#import "OCVCaptureModel.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import <Accelerate/Accelerate.h>
#import "Keypoint.h"
#import "OCVSimpleBlobs.h"
#import "RenderScene.h"
#import "CaptureTextureModel.h"
#import "Constants.h"

@interface OCVCaptureModel () <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    cv::vector< cv::KeyPoint> keyPoints;
    cv::vector< cv::vector <cv::Point> >  approxContours;
}

@property (strong) CaptureTextureModel *textureModel;
@property (strong) NSOperationQueue *detectQueue;

@end

@implementation OCVCaptureModel
+ (instancetype) sharedModel
{
    static id shared;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (id) init
{
    self = [super init];
    if( self )
    {
        self.detectQueue = [[NSOperationQueue alloc] init];
        self.detectQueue.name = @"com.noisederived.livephysics.detect";
        [self setupCapture];
    }

    return self;
}

- (void) setupCapture
{
    createBlobDetector(kDetectMinThresh, kDetectMaxThresh, kDetectThreshStep, kDetectMinDist);
    [self setupAVSession];
    [self setupCamTexture];
    [session startRunning];
}

- (void) setupCamTexture
{
    AVCaptureInput *input = [session.inputs objectAtIndex:0];
    AVCaptureInputPort *port = [input.ports objectAtIndex:0];
    CMFormatDescriptionRef formatDescription = port.formatDescription;
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription);
    NSLog(@"%i\t%i", dimensions.width, dimensions.height);
    CaptureTextureModel *captureModel = [CaptureTextureModel sharedModel];
    self.textureModel = captureModel;
    self.textureModel.cameraTexture = [[SKMutableTexture alloc] initWithSize:CGSizeMake(dimensions.width, dimensions.height) pixelFormat:kCVPixelFormatType_32RGBA];
}

- (void) setupAVSession
{
    NSError *error;
    session = [AVCaptureSession new];
//    [session setSessionPreset:AVCaptureSessionPresetHigh];
    
    for (AVCaptureDevice *device in [AVCaptureDevice devices]) {
        if ([device hasMediaType:AVMediaTypeVideo] || [device hasMediaType:AVMediaTypeMuxed]) {
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
            if (error) {
                NSLog(@"deviceInputWithDevice failed with error %@", [error localizedDescription]);
            }
            NSLog(@"%@", device.localizedName);

            if ([session canAddInput:input] && [device.localizedName isEqualToString:@"USB_Camera"])
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
    if( DEBUGIMAGE )
    {
        [self toCameraTexture:sampleBuffer];
    }
    
    [self toSingleChannel:sampleBuffer];
}

- (void) captureOutput:(AVCaptureOutput *)captureOutput didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    NSLog(@"Did drop");
}


#pragma mark - Detection

- (void) toSingleChannel:(CMSampleBufferRef)sampleBuffer
{
    CVImageBufferRef imageBuffer =  CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    size_t width = CVPixelBufferGetWidthOfPlane(imageBuffer, 0);
    size_t height = CVPixelBufferGetHeightOfPlane(imageBuffer, 0);
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
    
    Pixel_8 *lumaBuffer = (Pixel_8*)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    //    CGColorSpaceRef grayColorSpace = CGColorSpaceCreateDeviceGray();
    //    CGContextRef context = CGBitmapContextCreate(lumaBuffer, width, height, 8, bytesPerRow, grayColorSpace, kCGImageAlphaNone);
    
    vImage_Buffer imagebuf = {lumaBuffer, height, width, bytesPerRow};
    cv::Mat grayImage((int)imagebuf.height, (int)imagebuf.width, CV_8U, imagebuf.data, imagebuf.rowBytes);
    cv::Mat croppedRef(grayImage, cv::Rect(1920.f/2.f - 1280.f/2.f, 1080.f/2.f - 800.f/2.f, 1280.f, 800.f ));
    cv::resize(grayImage, grayImage, cv::Size(640, 400));
    
    detect(grayImage, &keyPoints, &approxContours );
    
    cv::vector<cv::KeyPoint>::iterator it;
    
    NSMutableArray *keypointsArray = [[NSMutableArray alloc] init];
    for( it= keyPoints.begin(); it!= keyPoints.end();it++)
    {
        Keypoint *thisKeypoint = [[Keypoint alloc] init];
        thisKeypoint.angle = it->angle;
        thisKeypoint.class_id = it->class_id;
        thisKeypoint.octave = it->octave;
        thisKeypoint.pt = CGPointMake(it->pt.x, it->pt.y);
        thisKeypoint.response = it->response;
        thisKeypoint.size = it->size;
        [keypointsArray addObject:thisKeypoint];
    }

    NSMutableArray *contoursArray = [NSMutableArray array];
    for ( cv::vector<cv::vector<cv::Point> >::iterator it1 = approxContours.begin(); it1 != approxContours.end(); ++it1 )
    {
        NSMutableArray *contourPoints = [NSMutableArray array];
        
        for ( std::vector<cv::Point>::iterator it2 = (*it1).begin(); it2 != (*it1).end(); ++ it2 )
        {
            NSPoint thisPoint = CGPointMake( it2->x, it2->y );
            [contourPoints addObject:[NSValue valueWithPoint:thisPoint]];
        }
        NSDictionary *contourDict = @{@"points": contourPoints};
        [contoursArray addObject:contourDict];
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if( [self.delegate respondsToSelector:@selector(captureModelDidFindKeypoints:)] )
        {
            [self.delegate captureModelDidFindKeypoints:keypointsArray];
        }
        
        if( [self.delegate respondsToSelector:@selector(captureModelDidFindContours:)] )
        {
            [self.delegate captureModelDidFindContours:contoursArray];
        }
    }];
    
    CVPixelBufferUnlockBaseAddress( imageBuffer, 0 );
    
    cv::vector< cv::KeyPoint>().swap(keyPoints);
    cv::vector< cv::vector <cv::Point> >().swap(approxContours);
    grayImage.release();
    croppedRef.release();
    //    CGContextRelease(context);
}


- (void) toCameraTexture:(CMSampleBufferRef)sampleBuffer
{
    // CHANGE TO IOSURFACE / CIIMAGE
    
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    unsigned long bufferHeight = CVPixelBufferGetHeight(pixelBuffer);
    unsigned long bufferWidth = CVPixelBufferGetWidth(pixelBuffer);
    //    unsigned long bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
    unsigned char *rowBase = (unsigned char *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    
    uint8_t *rgbBuffer = (uint8_t *)malloc(bufferWidth * bufferHeight * 4);
    uint8_t *yBuffer = rowBase;
    
    int bytesPerPixel = 4;
    // for each byte in the input buffer, fill in the output buffer with four bytes
    // the first byte is the Alpha channel, then the next three contain the same
    // value of the input buffer
    for(int y = 0; y < bufferWidth*bufferHeight; y++)
    {
        uint8_t val = yBuffer[bufferWidth * bufferHeight - y];
        // Alpha channel
        
        // next three bytes same as input
        rgbBuffer[(y*bytesPerPixel)] = rgbBuffer[(y*bytesPerPixel)+1] =  rgbBuffer[y*bytesPerPixel+2] = val;
        rgbBuffer[(y*bytesPerPixel)+3] = 0xff;
    }
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    [self.textureModel.cameraTexture modifyPixelDataWithBlock:^(void *pixelData, size_t lengthInBytes) {
        memcpy(pixelData, rgbBuffer, lengthInBytes);
    }];
    
    free(rgbBuffer);
}


@end
