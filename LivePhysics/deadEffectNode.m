//
//  DeadEffectNode.m
//  LivePhysics
//
//  Created by Voxels on 2/14/15.
//  Copyright (c) 2015 Noise Derived. All rights reserved.
//

#import "DeadEffectNode.h"

@interface DeadEffectNode ()

@property (strong) SKSpriteNode *spriteNode;
@property (assign) CGSize viewSize;

@end

@implementation DeadEffectNode


- (id) initWithView:(SKView *)skView
{
    self = [self init];
    if( self )
    {
        [self setupSpriteWithView:skView];
        [self setupFilter];
    }
    return self;
}


- (id) init
{
    self = [super init];
    if( self )
    {
        [self setShouldEnableEffects:YES];
    }
    return self;
}

- (void) setupSpriteWithView:(SKView *)skView
{
    self.viewSize = CGSizeMake( CGRectGetWidth(skView.bounds), CGRectGetHeight(skView.bounds) );
    self.spriteNode = [[SKSpriteNode alloc] init];
    self.spriteNode.size = skView.bounds.size;
    self.spriteNode.position = CGPointMake(CGRectGetMidX(skView.bounds), CGRectGetMidY(skView.bounds));
    [self addChild:self.spriteNode];
}

- (void) setupFilter
{
    self.xFormFilter = [self transformFilterWithDict:self.perspectiveDictionary];
    self.filter = self.xFormFilter;
}


- (void) updateSpriteTexture:(SKTexture *)updatedTexture
{
    self.spriteNode.texture = updatedTexture;
}


- (CIFilter *) positionFilterWithTranslation:(CGRect)calculatedRect
{
    NSAffineTransform *affineTransform = [NSAffineTransform transform];
    CGFloat scaleX = (CGRectGetMaxX(calculatedRect) - CGRectGetMinX(calculatedRect) ) / self.viewSize.width;
    CGFloat scaleY = (CGRectGetMaxY(calculatedRect) - CGRectGetMinY(calculatedRect) ) / self.viewSize.height;
    [affineTransform scaleXBy:scaleX * 10 yBy:scaleY * 10];
    //    [affineTransform translateXBy:-calculatedRect.origin.x yBy:-calculatedRect.origin.y ];
    
    //    NSLog(@"%f\t%f", calculatedRect.origin.x, calculatedRect.origin.y);
    
    CIFilter *transformFilter = [CIFilter filterWithName:@"CIAffineTransform"];
    [transformFilter setValue:affineTransform forKey:@"inputTransform"];
    return transformFilter;
}

- (CIFilter *) transformFilterWithDict:(NSDictionary *)transformDict
{
    CIFilter *transformFilter = [CIFilter filterWithName:@"CIPerspectiveTransform"];
    [transformFilter setValue:transformDict[@"topLeftVector"] forKey:@"inputTopLeft"];
    [transformFilter setValue:transformDict[@"topRightVector"] forKey:@"inputTopRight"];
    [transformFilter setValue:transformDict[@"bottomLeftVector"] forKey:@"inputBottomLeft"];
    [transformFilter setValue:transformDict[@"bottomRightVector"] forKey:@"inputBottomRight"];
    
    return transformFilter;
}

- (NSDictionary *)perspectiveDictionary
{
    CIVector *topLeftVector = [CIVector vectorWithX:0 Y:800];
    CIVector *bottomLeftVector = [CIVector vectorWithX:400 Y:0];

    CIVector *topRightVector = [CIVector vectorWithX:1280 Y:800];
    CIVector *bottomRightVector = [CIVector vectorWithX:1280 Y:0];
    
    NSDictionary *perspectiveDict = @{
                                      @"topLeftVector" : topLeftVector,
                                      @"topRightVector" : topRightVector,
                                      @"bottomLeftVector" : bottomLeftVector,
                                      @"bottomRightVector" : bottomRightVector
                                      };
    return perspectiveDict;
}

@end
