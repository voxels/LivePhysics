//
//  Keypoint.h
//  LivePhysics
//
//  Created by Voxels on 1/31/15.
//  Copyright (c) 2015 Noise Derived. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Keypoint : NSObject
@property (assign, nonatomic) CGFloat angle;        // Computed orientation of the keypoint (-1 if not applicable).
@property (assign, nonatomic) NSInteger class_id;   // Object ID, that can be used to cluster keypoints by an object they belong to.
@property (assign, nonatomic) NSInteger octave;     // Octave (pyramid layer), from which the keypoint has been extracted.
@property (assign, nonatomic) CGPoint pt;           // Coordinates of the keypoint.
@property (assign, nonatomic) CGFloat response;     // The response, by which the strongest keypoints have been selected.
@property (assign, nonatomic) CGFloat size;         // Diameter of the useful keypoint adjacent area.

@end
