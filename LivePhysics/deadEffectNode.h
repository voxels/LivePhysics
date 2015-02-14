//
//  DeadEffectNode.h
//  LivePhysics
//
//  Created by Voxels on 2/14/15.
//  Copyright (c) 2015 Noise Derived. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface DeadEffectNode : SKEffectNode

- (id) initWithView:(SKView *)skView;

- (void) updateSpriteTexture:(SKTexture *)updatedTexture forRect:(CGRect)calculatedRect;

@end
