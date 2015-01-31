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
#import "OutScene.h"

const CGFloat kDetectSessionWidth = 800.f;
const CGFloat kDetectSessionHeight = 600.f;

const CGFloat kDetectMinThresh = 0.f;
const CGFloat kDetectMaxThresh = 70.f;
const NSInteger kDetectThreshStep = 2;
const CGFloat kDetectMinDist = 30.f;

@interface OCVCaptureModel () <AVCaptureVideoDataOutputSampleBufferDelegate>


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
        [self setupAVSession];
        [session startRunning];
    }

    return self;
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
    [self toCameraTexture:sampleBuffer];
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
    cv::vector<cv::KeyPoint> keyPoints;
    cv::vector< cv::vector <cv::Point> >  approxContours;
    
    //    CGColorSpaceRef grayColorSpace = CGColorSpaceCreateDeviceGray();
    //    CGContextRef context = CGBitmapContextCreate(lumaBuffer, width, height, 8, bytesPerRow, grayColorSpace, kCGImageAlphaNone);
    
    vImage_Buffer imagebuf = {lumaBuffer, height, width, bytesPerRow};
    cv::Mat grayImage((int)imagebuf.height, (int)imagebuf.width, CV_8U, imagebuf.data, imagebuf.rowBytes);
    
    detect(grayImage, &keyPoints, &approxContours, kDetectMinThresh, kDetectMaxThresh, kDetectThreshStep, kDetectMinDist);
    
    if( [self.delegate respondsToSelector:@selector(captureModelDidFindKeypoints:)] )
    {
        [self.delegate captureModelDidFindKeypoints:[self recordKeypoints:keyPoints]];
    }
    
    if( [self.delegate respondsToSelector:@selector(captureModelDidFindContours:)] )
    {
        [self.delegate captureModelDidFindContours:[self recordContours:approxContours]];
    }
    
    //    CVPixelBufferUnlockBaseAddress( imageBuffer, 0 );
    //    CGContextRelease(context);
}


- (void) toCameraTexture:(CMSampleBufferRef)sampleBuffer
{
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    //    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    unsigned long bufferHeight = CVPixelBufferGetHeight(pixelBuffer);
    unsigned long bufferWidth = CVPixelBufferGetWidth(pixelBuffer);
    uint8_t *rowBase = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    
    uint8_t *rgbBuffer = (uint8_t *)malloc(bufferWidth * bufferHeight * 4);
    uint8_t *yBuffer = rowBase;
    uint8_t val;
    
    int bytesPerPixel = 4;
    
    // for each byte in the input buffer, fill in the output buffer with four bytes
    // the first byte is the Alpha channel, then the next three contain the same
    // value of the input buffer
    for(int y = 0; y < bufferWidth*bufferHeight; y++)
    {
        val = yBuffer[bufferWidth * bufferHeight - y];
        // Alpha channel
        
        // next three bytes same as input
        rgbBuffer[(y*bytesPerPixel)] = rgbBuffer[(y*bytesPerPixel)+1] =  rgbBuffer[y*bytesPerPixel+2] = val;
        rgbBuffer[(y*bytesPerPixel)+3] = 0xff;
    }
    
//    [self.outScene.cameraTexture modifyPixelDataWithBlock:^(void *pixelData, size_t lengthInBytes) {
//        NSLog(@"made texture");
//        memcpy(pixelData, rgbBuffer, lengthInBytes);
//    }];
}

- (NSArray *) recordKeypoints:(cv::vector<cv::KeyPoint>) keyPoints
{
    NSMutableArray *retval = [NSMutableArray array];
    
    cv::vector<cv::KeyPoint>::iterator it;
    
    for( it= keyPoints.begin(); it!= keyPoints.end();it++)
    {
        Keypoint *thisKeypoint = [[Keypoint alloc] init];
        thisKeypoint.angle = it->angle;
        thisKeypoint.class_id = it->class_id;
        thisKeypoint.octave = it->octave;
        thisKeypoint.pt = CGPointMake(it->pt.x, it->pt.y);
        thisKeypoint.response = it->response;
        thisKeypoint.size = it->size;
        [retval addObject:thisKeypoint];
    }
    
    return [NSArray arrayWithArray:retval];
}

- (NSArray *)recordContours:(cv::vector< cv::vector <cv::Point> >) approxContours
{
    NSMutableArray *retval = [NSMutableArray array];
    for ( cv::vector<cv::vector<cv::Point> >::iterator it1 = approxContours.begin(); it1 != approxContours.end(); ++it1 )
    {
        NSMutableArray *contourPoints = [NSMutableArray array];
        
        for ( std::vector<cv::Point>::iterator it2 = (*it1).begin(); it2 != (*it1).end(); ++ it2 )
        {
            NSPoint thisPoint = CGPointMake( it2->x, it2->y );
            [contourPoints addObject:[NSValue valueWithPoint:thisPoint]];
        }
        NSDictionary *contourDict = @{@"points": contourPoints};
        [retval addObject:contourDict];
    }
    
    return [NSArray arrayWithArray:retval];
}



@end