//
//  CaptureTextureModel.h
//  CamView
//
//  Created by Voxels on 1/24/15.
//  Copyright (c) 2015 Noise Derived. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface CaptureTextureModel : NSObject

+ (instancetype) sharedModel;
@property (strong) SKMutableTexture *cameraTexture;

@end

