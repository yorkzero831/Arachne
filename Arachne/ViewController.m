//
//  ViewController.m
//  Arachne
//
//  Created by york on 2017/12/5.
//  Copyright © 2017年 zero. All rights reserved.
//
#import <Vision/Vision.h>
#import "ViewController.h"
#import "PlaneNode.h"


@interface ViewController () <ARSCNViewDelegate, ARSessionDelegate>

@property (nonatomic, strong) IBOutlet ARSCNView *sceneView;

@end

    
@implementation ViewController {
    
    ARAnchor *detectedAnchor;
    NSMutableDictionary *plandic;
    VNDetectBarcodesRequest *barcodeDetecion;
    VNSequenceRequestHandler *barcodeRequest;
    dispatch_queue_t barcodeQueue;
    BOOL isDetected;
    BOOL isSetted;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Set the view's delegate
    self.sceneView.delegate = self;
    
    self.sceneView.session.delegate = self;
    
    // Show statistics such as fps and timing information
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

//- (void)renderer:(id<SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
//    if([anchor isKindOfClass: [ARPlaneAnchor class]]) {
////        PlaneNode * plane = [[PlaneNode alloc] init];
////        [plane initWithAnchor:anchor];
////
////        plandic[anchor.identifier] = plane;
////        [node addChildNode:plane];
//    }
//}

- (void)renderer:(id<SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    
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

- (SCNNode *) renderer:(id<SCNSceneRenderer>)renderer nodeForAnchor:(ARAnchor *)anchor {
    if(detectedAnchor!= nil) {
        if(detectedAnchor.identifier == anchor.identifier) {
            
            SCNPlane *plane = [[SCNPlane alloc] init];
            [plane setWidth:.01];
            [plane setHeight:.01];
            SCNMaterial *material = [[SCNMaterial alloc] init];
            material.lightingModelName = SCNLightingModelLambert;
            [plane setMaterials:@[material]];
            
            SCNNode *node = [SCNNode nodeWithGeometry:plane];
            return node;
        }
    }
    return nil;
}


- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame {
    
    if(isDetected) {
        return;
    }
    
    CVPixelBufferRef ref = [frame capturedImage];
    CIImage *image = [CIImage imageWithCVImageBuffer:ref];
    dispatch_async(barcodeQueue, ^{
        if([barcodeRequest performRequests:@[barcodeDetecion] onCIImage:image error:nil]) {
            NSArray *barcodeArray = [barcodeDetecion results];
            VNBarcodeObservation *result = [barcodeArray firstObject];
            CGRect rect = [result boundingBox];
            
            rect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeScale(1, -1));
            rect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeTranslation(0, 1));
            
            CGPoint center = CGPointMake( rect.origin.x, rect.origin.y);
            
//            if(barcodeArray.count != 0) {
//                NSLog(@"YES %d", barcodeArray.count);
//            }
            
            NSArray *hitTestResults = [frame hitTest:center types:ARHitTestResultTypeFeaturePoint];
            if(hitTestResults.count != 0) {
                NSLog(@"YES %d", hitTestResults.count);
                ARHitTestResult *hitTestResult = [hitTestResults firstObject];
                if(detectedAnchor == nil){
                    detectedAnchor = [[ARAnchor alloc] initWithTransform:hitTestResult.worldTransform];
                    [self.sceneView.session addAnchor:detectedAnchor];
                    isDetected = true;
                } else {
                    //if(isSetted) return;
                    SCNNode *node = [self.sceneView nodeForAnchor:detectedAnchor];
                    node.transform = SCNMatrix4FromMat4(hitTestResult.worldTransform);
                    [node localTranslateBy:SCNVector3Make(-0.03, 0, -0.01)];
                    node.rotation =SCNVector4Make(1, 0, 0, -M_PI/2);
                    //isSetted = true;
                }
                
            }
        }
    });
    
}


@end
