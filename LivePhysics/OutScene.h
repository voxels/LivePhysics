//
//  OutScene.h
//  LivePhysics
//
//  Created by Voxels on 1/31/15.
//  Copyright (c) 2015 Noise Derived. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SpriteKit/SpriteKit.h>

@interface OutScene : SKScene

@property (strong) SKMutableTexture *cameraTexture;

- (void) addKeyPoints:(NSArray *) keypoints;
- (void) addContours:(NSArray *)contours;


@end
