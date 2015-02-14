//
//  AppDelegate.m
//  LivePhysics
//
//  Created by Voxels on 1/27/15.
//  Copyright (c) 2015 Noise Derived. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property NSWindowController *skewController;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"Main" bundle:nil]; // get a reference to the storyboard
    _skewController = [storyBoard instantiateControllerWithIdentifier:@"skewWindowController"]; // instantiate your window controller
    _skewController.window.acceptsMouseMovedEvents = YES;
    [_skewController showWindow:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
