//
//  ARManagerView.m
//  Arachne
//
//  Created by york on 2017/12/8.
//  Copyright © 2017年 zero. All rights reserved.
//
#import <Vision/Vision.h>
#import "ARManagerView.h"
#import "worldPlane.h"


@implementation ARManagerView{
    
    ARAnchor *detectedAnchor;
    NSMutableDictionary *plandic;
    dispatch_queue_t barcodeQueue;
    
    //image witdh
    CGFloat iw;
    //image height
    CGFloat ih;
    
    
    WorldPlane *worldPlane;
    NSUUID *worldPlaneId;
    BOOL isWorldPlaneDefined;
    BOOL isWorldPlaneFinished;
    int worldPlaneUpdateTimes;
    
    float qrcodeCorners[8];
    
    BOOL isDetected;
    BOOL isSetted;
    
    double rotateAnge;
    SCNVector3 centerPoint;
    
    NSString* selectBlockName;
    
}

- (void) ARManagerViewLoaded {
    self.delegate = self;
    self.session.delegate = self;
    self.showsStatistics = true;
    self.debugOptions = ARSCNDebugOptionShowWorldOrigin | ARSCNDebugOptionShowFeaturePoints;
    
    // Create a new scene
    SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/ship.scn"];
    
    // Set the scene to the view
    self.scene = scene;
    
    barcodeQueue = dispatch_queue_create("york_barcode_queue", nil);
    detectedAnchor = nil;
    isDetected = false;
    isSetted = false;
    isWorldPlaneDefined = false;
    isWorldPlaneFinished = false;
    worldPlaneUpdateTimes = 0;
    
}

- (void) ARManagerViewConfigureSession {
    // Create a session configuration
    ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];
    configuration.planeDetection = ARPlaneDetectionHorizontal;
    
    // Run the view's session
    [self.session runWithConfiguration:configuration];
}

- (void) ARManagerViewStop {
    [self.session pause];
}

- (void)renderer:(id <SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    if (![anchor isKindOfClass:[ARPlaneAnchor class]]) {
        return;
    }
    if(!isWorldPlaneDefined) {
        NSLog(@"get plane");
        WorldPlane *plane = [[WorldPlane alloc] initWithAnchor: (ARPlaneAnchor *)anchor];
        worldPlane = plane;
        worldPlaneId = anchor.identifier;
        [node addChildNode:plane];
        isWorldPlaneDefined = true;
    }
}

- (void)renderer:(id<SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    if(isWorldPlaneDefined) {
        if (anchor.identifier == worldPlaneId) {
            [worldPlane update:anchor];
            if (!isWorldPlaneFinished) {
                worldPlaneUpdateTimes ++;
                if(worldPlaneUpdateTimes > 10) {
                    [[[worldPlane planeGeometry] materials] firstObject].transparency = 0.0;
                    isWorldPlaneFinished = true;
                }
            }
            
        }
    }
}

- (void) renderer:(id<SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    
}

- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
    // Present an error message to the user
    
}

- (void)sessionWasInterrupted:(ARSession *)session {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
    
}

- (void)sessionInterruptionEnded:(ARSession *)session {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
    
}

- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame {
    
    if(isDetected || !isWorldPlaneFinished) {
        return;
    }
    
    CVPixelBufferRef ref = [frame capturedImage];
    CIImage *image = [CIImage imageWithCVImageBuffer:ref];
    dispatch_async(barcodeQueue, ^{
        
        iw = image.extent.size.width;
        ih = image.extent.size.height;
        
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:nil];
        NSArray<CIFeature *> *features = [detector featuresInImage:image];
        if (features.count > 0) {
            CIQRCodeFeature *feature = (CIQRCodeFeature*) [features objectAtIndex:0];
            
            float qrCor[8];
            
            qrCor[0] = feature.topLeft.x / iw;
            qrCor[1] = 1- feature.topLeft.y / ih;
            qrCor[2] = feature.topRight.x / iw;
            qrCor[3] = 1- feature.topRight.y / ih;
            qrCor[4] = feature.bottomLeft.x / iw;
            qrCor[5] = 1- feature.bottomLeft.y / ih;
            qrCor[6] = feature.bottomRight.x / iw;
            qrCor[7] = 1- feature.bottomRight.y / ih;
            
            NSArray<ARHitTestResult *> *rTL = [frame hitTest:CGPointMake(qrCor[0], qrCor[1]) types:ARHitTestResultTypeExistingPlane];
            
            NSArray<ARHitTestResult *> *rTR = [frame hitTest:CGPointMake(qrCor[2], qrCor[3]) types:ARHitTestResultTypeExistingPlane];
            
            NSArray<ARHitTestResult *> *rBL = [frame hitTest:CGPointMake(qrCor[4], qrCor[5]) types:ARHitTestResultTypeExistingPlane];
            
            NSArray<ARHitTestResult *> *rBR = [frame hitTest:CGPointMake(qrCor[6], qrCor[7]) types:ARHitTestResultTypeExistingPlane];
            
            if(rTL.count != 0 && rTR.count !=0 && rBL.count != 0 && rBR.count != 0) {
                NSLog(@"GOT");
                
                SCNNode *box1 = [self.scene.rootNode childNodeWithName:@"box1" recursively:YES];
                [box1 setTransform:SCNMatrix4FromMat4([[rTL firstObject] worldTransform])];
                matrix_float4x4 m1 = [[rTL firstObject] worldTransform];
                [box1 setScale:SCNVector3Make(0.01, 0.01, 0.01)];
                NSLog(@"x:%f y:%f z:%f", box1.position.x, box1.position.y, box1.position.z);
                
                SCNNode *box2 = [self.scene.rootNode childNodeWithName:@"box2" recursively:YES];
                [box2 setTransform:SCNMatrix4FromMat4([[rTR firstObject] worldTransform])];
                matrix_float4x4 m2 = [[rTR firstObject] worldTransform];
                [box2 setScale:SCNVector3Make(0.01, 0.01, 0.01)];
                NSLog(@"x:%f y:%f z:%f", box2.position.x, box2.position.y, box2.position.z);
                
                SCNNode *box3 = [self.scene.rootNode childNodeWithName:@"box3" recursively:YES];
                [box3 setTransform:SCNMatrix4FromMat4([[rBL firstObject] worldTransform])];
                matrix_float4x4 m3 = [[rBL firstObject] worldTransform];
                [box3 setScale:SCNVector3Make(0.01, 0.01, 0.01)];
                NSLog(@"x:%f y:%f z:%f", box3.position.x, box3.position.y, box3.position.z);
                
                SCNNode *box4 = [self.scene.rootNode childNodeWithName:@"box4" recursively:YES];
                [box4 setTransform:SCNMatrix4FromMat4([[rBR firstObject] worldTransform])];
                matrix_float4x4 m4 = [[rBR firstObject] worldTransform];
                [box4 setScale:SCNVector3Make(0.01, 0.01, 0.01)];
                NSLog(@"x:%f y:%f z:%f", box4.position.x, box3.position.y, box3.position.z);
                
                double x = rTL.firstObject.worldTransform.columns[3][0] - rBL.firstObject.worldTransform.columns[3][0];
                double y = rTL.firstObject.worldTransform.columns[3][2] - rBL.firstObject.worldTransform.columns[3][2];
                
                double a = sqrtf(x*x + y*y);
                
                CGPoint qv = CGPointMake(x / a, y / a);
                CGPoint ve = CGPointMake(0,  -1);
                double cosAngle = (qv.x * ve.x + qv.y * ve.y)/
                ( sqrtf(qv.x * qv.x + qv.y * qv.y) * sqrtf(ve.x * ve.x + ve.y * ve.y) );
                double thelt = acos(cosAngle);
                if(qv.x < 0) thelt = -thelt;
                
                [box1 setRotation:SCNVector4Make(0, 1, 0, -thelt)];
                [box2 setRotation:SCNVector4Make(0, 1, 0, -thelt)];
                [box3 setRotation:SCNVector4Make(0, 1, 0, -thelt)];
                [box4 setRotation:SCNVector4Make(0, 1, 0, -thelt)];
                
                double centerX = ( rTL.firstObject.worldTransform.columns[3][0] + rBL.firstObject.worldTransform.columns[3][0] + rTR.firstObject.worldTransform.columns[3][0] + rBR.firstObject.worldTransform.columns[3][0] ) /4;
                double centerY = ( rTL.firstObject.worldTransform.columns[3][1] + rBL.firstObject.worldTransform.columns[3][1] + rTR.firstObject.worldTransform.columns[3][1] + rBR.firstObject.worldTransform.columns[3][1] ) /4;
                double centerZ = ( rTL.firstObject.worldTransform.columns[3][2] + rBL.firstObject.worldTransform.columns[3][2] + rTR.firstObject.worldTransform.columns[3][2] + rBR.firstObject.worldTransform.columns[3][2] ) /4;
                
                SCNNode *world = [self.scene.rootNode childNodeWithName:@"Arachne" recursively:YES];
                [world setPosition:SCNVector3Make(centerX, centerY, centerZ)];
                [world setRotation:SCNVector4Make(0, 1, 0, -thelt)];
                NSLog(@"x:%f y:%f z:%f", world.position.x, world.position.y, world.position.z);
                
                rotateAnge = thelt;
                centerPoint = SCNVector3Make(centerX, centerY, centerZ);
                isDetected = true;
            }
        }
    });
    
}

#pragma mark UITouch
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"touched");
    UITouch *touch = [[touches allObjects] firstObject];
    CGPoint point = [touch locationInView:self];
    NSLog(@"x: %f, y:%f", point.x, point.y);
    [self createBlock: point];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

#pragma mark Block
- (void)setSelectBlockName :(NSString*)name {
    selectBlockName = name;
}

- (void)createBlock :(CGPoint)point {
    CGRect screenBounds = [self bounds];
    
    float x = point.x ;/// screenBounds.size.width;
    float y = point.y; /// screenBounds.size.height;
    NSLog(@"x: %f, y:%f", x, y);
    
    NSArray<ARHitTestResult *> *resluts = [self hitTest:CGPointMake(x, y) types:ARHitTestResultTypeExistingPlane];
    if(resluts.count != 0){
        SCNBox *box = [[SCNBox alloc] init];
        SCNNode *node = [SCNNode nodeWithGeometry:box];
        
        float px = resluts.firstObject.worldTransform.columns[3][0] + centerPoint.x;
        float py = resluts.firstObject.worldTransform.columns[3][1];
        float pz = resluts.firstObject.worldTransform.columns[3][2];
        
        NSLog(@"x:%f y:%f z:%f", px, py, pz);
        
        [node setPosition:SCNVector3Make(px, py, pz)];
        [node setRotation:SCNVector4Make(0, 1, 0, -rotateAnge)];
        [node setScale:SCNVector3Make(0.02, 0.02, 0.02)];
        [self.scene.rootNode addChildNode:node];
    }
}


@end
