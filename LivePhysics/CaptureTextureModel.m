//
//  CaptureTextureModel.m
//  CamView
//
//  Created by Voxels on 1/24/15.
//  Copyright (c) 2015 Noise Derived. All rights reserved.
//

#import "CaptureTextureModel.h"

@implementation CaptureTextureModel

+ (instancetype) sharedModel
{
    static id shared;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

@end
