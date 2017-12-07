//
//  plane.m
//  Arachne
//
//  Created by 兪　哲人 on 2017/12/07.
//  Copyright © 2017年 zero. All rights reserved.
//

#import "worldPlane.h"

@implementation WorldPlane

- (instancetype)initWithAnchor:(ARPlaneAnchor *)anchor {
    self = [super init];
    
    self.anchor = anchor;
    self.planeGeometry = [SCNPlane planeWithWidth:anchor.extent.x height:anchor.extent.z];
    
    SCNMaterial *material = [SCNMaterial new];
//    UIImage *img = [UIImage imageNamed:@"tron_grid"];
//    material.diffuse.contents = img;
    material.transparency = 0.5;
    self.planeGeometry.materials = @[material];
    
    SCNNode *planeNode = [SCNNode nodeWithGeometry:self.planeGeometry];
    planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z);
    
    planeNode.transform = SCNMatrix4MakeRotation(-M_PI / 2.0, 1.0, 0.0, 0.0);
    
    [self addChildNode:planeNode];
    return self;
}

- (void)update:(ARPlaneAnchor *)anchor {
    self.planeGeometry.width = anchor.extent.x;
    self.planeGeometry.height = anchor.extent.z;
    
    self.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z);
}

@end
