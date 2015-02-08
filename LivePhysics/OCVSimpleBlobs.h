//
//  OCVSimpleBlobs.h
//  LivePhysics
//
//  Created by Voxels on 1/27/15.
//  Copyright (c) 2015 Noise Derived. All rights reserved.
//

#ifndef __LivePhysics__OCVSimpleBlobs__
#define __LivePhysics__OCVSimpleBlobs__

#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/highgui/highgui.hpp"

#include <iostream>
#include <math.h>
#include <vector>
#include <fstream>
#include <string>
#include <sstream>
#include <algorithm>

#include <opencv2/objdetect/objdetect.hpp>
#include <opencv2/features2d/features2d.hpp>
#include <opencv2/core/core.hpp>

#endif /* defined(__LivePhysics__OCVSimpleBlobs__) */

void createBlobDetector(float minThresh, float maxThresh, int threshStep, float minDistBetweenBlobs);
void detect( cv::Mat image, cv::vector<cv::KeyPoint> *_keyPoints, cv::vector< cv::vector <cv::Point> >  *_approxContours );