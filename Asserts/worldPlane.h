//
//  plane.h
//  Arachne
//
//  Created by 兪　哲人 on 2017/12/07.
//  Copyright © 2017年 zero. All rights reserved.
//

#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>

@interface WorldPlane : SCNNode
- (instancetype)initWithAnchor:(ARPlaneAnchor *)anchor;
- (void)update:(ARPlaneAnchor *)anchor;
@property (nonatomic,retain) ARPlaneAnchor *anchor;
@property (nonatomic, retain) SCNPlane *planeGeometry;

@end
