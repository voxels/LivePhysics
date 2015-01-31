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

void detect( cv::Mat image, cv::vector<cv::KeyPoint> *_keyPoints, cv::vector< cv::vector <cv::Point> >  *_approxContours )
{
    const char *wndNameOut = "Out";
    
    Mat src, gray, thresh, inverted;
    Mat out;
    vector<KeyPoint> keyPoints;
    vector< vector <Point> > contours;
    std::vector<cv::Vec4i > hierarchy;
    vector< vector <Point> > approxContours;
    
    SimpleBlobDetector::Params params;
    params.minThreshold = 0;
    params.maxThreshold = 70;
    params.thresholdStep = 1;
    
    params.minArea = 10.0;
    params.minConvexity = 0.9;
    params.minInertiaRatio = 0.2;
    params.maxInertiaRatio = 0.5;
    
    params.maxArea = 100.0;
    params.maxConvexity = 10;
    params.minDistBetweenBlobs = 30.0;
    params.filterByColor = false;
    params.filterByCircularity = false;
    
    blur( image, image, Size(4, 4));
    namedWindow( wndNameOut, CV_GUI_NORMAL );
    
    SimpleBlobDetector blobDetector = SimpleBlobDetector(params);
    ;
    blobDetector.detect( image, *_keyPoints );
    drawKeypoints( image, *_keyPoints, out, Scalar(0,255,0), DrawMatchesFlags::DEFAULT);
    Canny( image, thresh, 0, 150, 3 );

    findContours(thresh, contours, hierarchy, CV_RETR_CCOMP, CV_CHAIN_APPROX_NONE);

    approxContours.resize(contours.size());

    for( int i = 0; i < contours.size(); ++i )
    {
        approxPolyDP( Mat(contours[i]),  approxContours[i], 4, 1 );
//        drawContours( out, contours, i, Scalar(rand()&255, rand()&255, rand()&255) );
        drawContours( out, approxContours, i, Scalar(rand()&255, rand()&255, rand()&255) );
    }
    
    *_approxContours = approxContours;
    moveWindow(wndNameOut, 100, 100);
    imshow( wndNameOut, out );
}