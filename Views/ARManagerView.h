//
//  ARManagerView.h
//  Arachne
//
//  Created by york on 2017/12/8.
//  Copyright © 2017年 zero. All rights reserved.
//

#import <ARKit/ARKit.h>

@interface ARManagerView : ARSCNView<ARSCNViewDelegate, ARSessionDelegate>

- (void) ARManagerViewLoaded;
- (void) ARManagerViewConfigureSession;
- (void) ARManagerViewStop;

@end
