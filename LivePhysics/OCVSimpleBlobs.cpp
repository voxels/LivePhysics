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

void detect( cv::Mat image )
{
    const char *wndNameOut = "Out";
    
    Mat src, gray, thresh, binary;
    Mat out;
    vector<KeyPoint> keyPoints;
//    vector< vector <Point> > contours;
//    vector< vector <Point> > approxContours;
    
    SimpleBlobDetector::Params params;
    params.minThreshold = 60;
    params.maxThreshold = 80;
    params.thresholdStep = 1;
    
    params.minArea = 15.0;
    params.minConvexity = 0.3;
    params.minInertiaRatio = 0.05;
    
    params.maxArea = 50.0;
    params.maxConvexity = 10;
    
    params.filterByColor = false;
    params.filterByCircularity = false;
    
    namedWindow( wndNameOut, CV_GUI_NORMAL );
    
    SimpleBlobDetector blobDetector = SimpleBlobDetector(params);
    ;
    
        blobDetector.detect( image, keyPoints );
        drawKeypoints( image, keyPoints, out, Scalar(0,255,0), DrawMatchesFlags::DEFAULT);

//        approxContours.resize( contours.size() );
//        
//        for( int i = 0; i < contours.size(); ++i )
//        {
//            approxPolyDP( Mat(contours[i]), approxContours[i], 4, 1 );
//            drawContours( out, contours, i, Scalar(rand()&255, rand()&255, rand()&255) );
//            drawContours( out, approxContours, i, Scalar(rand()&255, rand()&255, rand()&255) );
//        }
//        cout << "Keypoints " << keyPoints.size() << " Countours " << contours.size() << endl;
        imshow( wndNameOut, out );
}