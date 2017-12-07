//
//  ViewController.m
//  Arachne
//
//  Created by york on 2017/12/5.
//  Copyright © 2017年 zero. All rights reserved.
//
#import <Vision/Vision.h>
#import "ViewController.h"
#import "worldPlane.h"



@interface ViewController () <ARSCNViewDelegate, ARSessionDelegate>

@property (nonatomic, strong) IBOutlet ARSCNView *sceneView;

@end

    
@implementation ViewController {
    
    ARAnchor *detectedAnchor;
    NSMutableDictionary *plandic;
    VNDetectBarcodesRequest *barcodeDetecion;
    VNSequenceRequestHandler *barcodeRequest;
    dispatch_queue_t barcodeQueue;
    
    WorldPlane *worldPlane;
    NSUUID *worldPlaneId;
    BOOL isWorldPlaneDefined;
    BOOL isWorldPlaneFinished;
    int worldPlaneUpdateTimes;
    
    float qrcodeCorners[8];
    
    BOOL isDetected;
    BOOL isSetted;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.sceneView.delegate = self;
    
    self.sceneView.session.delegate = self;
    
    self.sceneView.showsStatistics = YES;
    
    self.sceneView.debugOptions = ARSCNDebugOptionShowWorldOrigin | ARSCNDebugOptionShowFeaturePoints;
    
    // Create a new scene
    SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/ship.scn"];
    
    // Set the scene to the view
    self.sceneView.scene = scene;
    
    plandic = [NSMutableDictionary dictionary];
    
    barcodeDetecion = [[VNDetectBarcodesRequest alloc] init];
    barcodeRequest = [[VNSequenceRequestHandler alloc] init];
    barcodeQueue = dispatch_queue_create("york_barcode_queue", nil);
    detectedAnchor = nil;
    isDetected = false;
    isSetted = false;
    isWorldPlaneDefined = false;
    isWorldPlaneFinished = false;
    worldPlaneUpdateTimes = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Create a session configuration
    ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];
    configuration.planeDetection = ARPlaneDetectionHorizontal;

    // Run the view's session
    [self.sceneView.session runWithConfiguration:configuration];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Pause the view's session
    [self.sceneView.session pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - ARSCNViewDelegate

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
        
        CGRect screenBounds = UIScreen.mainScreen.bounds;
        CGFloat screenScale = UIScreen.mainScreen.scale;
        CGFloat sw = screenBounds.size.width * 1;
        CGFloat sh = screenBounds.size.height * 1;
        CGFloat iw = image.extent.size.width;
        CGFloat ih = image.extent.size.height;
        
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:nil];
        NSArray<CIFeature *> *features = [detector featuresInImage:image];
        if (features.count > 0) {
            CIQRCodeFeature *feature = (CIQRCodeFeature*) [features objectAtIndex:0];
            
            float qrCor[8];
            
            qrCor[0] = sw - feature.topLeft.y     * sw / ih;
            qrCor[1] = sh - feature.topLeft.x     * sh / iw;
            qrCor[2] = sw - feature.topRight.y    * sw / ih;
            qrCor[3] = sh - feature.topRight.x    * sh / iw;
            qrCor[4] = sw - feature.bottomRight.y * sw / ih;
            qrCor[5] = sh - feature.bottomRight.x * sh / iw;
            qrCor[6] = sw - feature.bottomLeft.y  * sw / ih;
            qrCor[7] = sh - feature.bottomLeft.x  * sh / iw;
            
            NSArray<ARHitTestResult *> *rTL = [frame hitTest:CGPointMake(0, 0) types:ARHitTestResultTypeExistingPlane];
            
            NSArray<ARHitTestResult *> *rTR = [frame hitTest:CGPointMake(sw, 0) types:ARHitTestResultTypeExistingPlane];
            
            NSArray<ARHitTestResult *> *rBL = [frame hitTest:CGPointMake(0, sh) types:ARHitTestResultTypeExistingPlane];
            
            NSArray<ARHitTestResult *> *rBR = [frame hitTest:CGPointMake(sw, sh) types:ARHitTestResultTypeExistingPlane];
            
            if(rTL.count != 0 && rTR.count !=0 && rBL.count != 0 && rBR.count != 0) {
                NSLog(@"GOT");
                
                SCNNode *box1 = [_sceneView.scene.rootNode childNodeWithName:@"box1" recursively:YES];
                [box1 setTransform:SCNMatrix4FromMat4([[rTL firstObject] worldTransform])];
                [box1 setScale:SCNVector3Make(0.01, 0.01, 0.01)];
                NSLog(@"x:%f y:%f z:%f", box1.position.x, box1.position.y, box1.position.z);
                
                SCNNode *box2 = [_sceneView.scene.rootNode childNodeWithName:@"box2" recursively:YES];
                [box2 setTransform:SCNMatrix4FromMat4([[rTR firstObject] worldTransform])];
                [box2 setScale:SCNVector3Make(0.01, 0.01, 0.01)];
                SCNNode *box3 = [_sceneView.scene.rootNode childNodeWithName:@"box3" recursively:YES];
                [box3 setTransform:SCNMatrix4FromMat4([[rBL firstObject] worldTransform])];
                [box3 setScale:SCNVector3Make(0.01, 0.01, 0.01)];
                SCNNode *box4 = [_sceneView.scene.rootNode childNodeWithName:@"box4" recursively:YES];
                [box4 setTransform:SCNMatrix4FromMat4([[rBR firstObject] worldTransform])];
                [box4 setScale:SCNVector3Make(0.01, 0.01, 0.01)];
                isDetected = true;
            }
        }
//        if([barcodeRequest performRequests:@[barcodeDetecion] onCIImage:image error:nil]) {
//            NSArray *barcodeArray = [barcodeDetecion results];
//            VNBarcodeObservation *result = [barcodeArray firstObject];
//            CGRect rect = [result boundingBox];
//
//            rect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeScale(1, -1));
//            rect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeTranslation(0, 1));
//
//            CGPoint center = CGPointMake( rect.origin.x, rect.origin.y);
//
////            if(barcodeArray.count != 0) {
////                NSLog(@"YES %d", barcodeArray.count);
////            }
//
//            NSArray *hitTestResults = [frame hitTest:center types:ARHitTestResultTypeFeaturePoint];
//            if(hitTestResults.count != 0) {
//                NSLog(@"YES %d", hitTestResults.count);
//                ARHitTestResult *hitTestResult = [hitTestResults firstObject];
//                if(detectedAnchor == nil){
//                    detectedAnchor = [[ARAnchor alloc] initWithTransform:hitTestResult.worldTransform];
//                    [self.sceneView.session addAnchor:detectedAnchor];
//                    isDetected = true;
//                } else {
//                    //if(isSetted) return;
//                    SCNNode *node = [self.sceneView nodeForAnchor:detectedAnchor];
//                    node.transform = SCNMatrix4FromMat4(hitTestResult.worldTransform);
//                    [node localTranslateBy:SCNVector3Make(-0.03, 0, -0.01)];
//                    node.rotation =SCNVector4Make(1, 0, 0, -M_PI/2);
//                    //isSetted = true;
//                }
//
//            }
//        }
    });
    
}


@end
