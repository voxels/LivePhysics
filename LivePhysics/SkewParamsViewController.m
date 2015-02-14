//
//  SkewParamsViewController.m
//  LivePhysics
//
//  Created by Voxels on 2/14/15.
//  Copyright (c) 2015 Noise Derived. All rights reserved.
//

#import "SkewParamsViewController.h"
#import <SpriteKit/SpriteKit.h>
#import "SkewScene.h"

@interface SkewParamsViewController ()
@property (weak) IBOutlet SKView *skewSceneView;
@property SkewScene *skewScene;
@end

@implementation SkewParamsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    if( !_skewScene )
    {
        self.skewScene = [[SkewScene alloc] initWithSize:CGSizeMake(640, 400)];
    }
    
    [self.skewSceneView setShowsNodeCount:YES];
    [self.skewSceneView presentScene:self.skewScene];
}


#pragma mark - View controller

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}


@end
