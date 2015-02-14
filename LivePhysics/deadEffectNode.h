//
//  DeadEffectNode.h
//  LivePhysics
//
//  Created by Voxels on 2/14/15.
//  Copyright (c) 2015 Noise Derived. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface DeadEffectNode : SKEffectNode

@property CIFilter *xFormFilter;

- (id) initWithView:(SKView *)skView;

- (void) updateSpriteTexture:(SKTexture *)updatedTexture;

@end
