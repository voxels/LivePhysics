//
//  OCVSimpleBlobs.cpp
//  LivePhysics
//
//  Created by Voxels on 1/27/15.
//  Copyright (c) 2015 Noise Derived. All rights reserved.
//

#include "OCVSimpleBlobs.h"

using namespace cv;
using namespace std;

static SimpleBlobDetector blobDetector;

void createBlobDetector(float minThresh, float maxThresh, int threshStep, float minDistBetweenBlobs)
{
    SimpleBlobDetector::Params params;
    params.minThreshold = minThresh;
    params.maxThreshold = maxThresh;
    params.thresholdStep = threshStep;
    
    params.minArea = 10.0;
    params.minConvexity = 0.9;
    params.minInertiaRatio = 0.2;
    params.maxInertiaRatio = 0.5;
    
    params.maxArea = 100.0;
    params.maxConvexity = 10;
    params.minDistBetweenBlobs = minDistBetweenBlobs;
    params.filterByColor = false;
    params.filterByCircularity = false;

    blobDetector = SimpleBlobDetector(params);
}

void detect( cv::Mat image, cv::vector<cv::KeyPoint> *_keyPoints, cv::vector< cv::vector <cv::Point> >  *_approxContours )
{
    Mat thresh;
    Mat out;
    vector< vector <Point> > contours;
    std::vector<cv::Vec4i> hierarchy;
    vector< vector <Point> > approxContours;
    
    blur( image, image, Size(4, 4));
    blobDetector.detect( image, *_keyPoints );
    Canny( image, thresh, 100, 150, 3 );
    findContours(thresh, contours, hierarchy, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE);

    approxContours.resize(contours.size());

    for( int i = 0; i < contours.size(); ++i )
    {
        approxPolyDP( Mat(contours[i]),  approxContours[i], 2, 0 );
    }
    
    *_approxContours = approxContours;
//        *_approxContours = contours;
    
    vector< vector <Point> >().swap(contours);
    std::vector<cv::Vec4i>().swap(hierarchy);
    vector< vector <Point> >().swap(approxContours);
    thresh.release();
    out.release();
}