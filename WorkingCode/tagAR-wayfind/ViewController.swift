//
//  ViewController.swift
//  tagAR-wayfind
//
//  Created by Lenny Martinez on 12/11/17.
//  Copyright © 2017 Lenny Martinez. All rights reserved.
//

import UIKit 
import SceneKit
import ARKit //used to build the AR view
import MapKit //used to get location information
import Foundation //used to process the transformation that has to happen
import GLKit //used to process the transformation that has to happen.
//import SpriteKit //an alternative Kit to working with SceneKit. SceneKit was chosen because Renee was already working on SceneKit
//what follows are a series of other modules used to connect to Renee's app. They aren't imported in this project because this was meant to be a demo of the feature
//import FirebaseAuth
//import Firebase
//import ARCL


class ViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate {
    
    //Connect the View of the AR Scene with the code. Let's us modify what one sees on the camera
    @IBOutlet var sceneView: ARSCNView!

    //I initiate an instance of CLLocationManager which is used to manage where locations are generated and stored in MapKit and will be used for calculations. 

    let locationManager = CLLocationManager()
    

    override func viewDidLoad() {
        super.viewDidLoad()

      /* This section asks the user to share their location for the purposes of the function.
         
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
         
        if CLLocationManager.locationServicesEnabled(){
         // if location services have been enabled, the app will start keeping track of the user's location at the most accurate option, and also update it constantly.
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        */
        //this is the code for the system to store the user's location to a variable
        //let sourceCoordinates = locationManager.location?.coordinate
        //for testing purposes, source and dest(ination) coordinateswere hard coded into the system. Source is my Aunt's apartment in Barcelona, and Dest is the coffee shop that's nearby.
        weak var source = CLLocation(latitude: 41.372521, longitude:2.1072745)
        weak var dest = CLLocation(latitude: 41.3721511, longitude: 2.1081629)
       
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        //This section creates the pyramid that I want to use as an arrow for the guiding.
        
        //first we create a pyramid with the described sizes.
        let pyr = SCNPyramid(width: 0.2, height: 0.2, length: 0.2)
        //scenes in ARKIT work with a hierarchy of nodes, so we make a new node for the pyramid
        let pyrNode = SCNNode()
        // now we assign that newly made node with the geometry of the pyramid, and then we place it in the x,y,z axis with respect to the camera (and where -y is down).
        pyrNode.geometry = pyr
        pyrNode.position = SCNVector3(0.3,0.0,0)
        
        //Here we calculate the angle that the arrow has to rotate to go from straight pointing away from the camera to location. This part would be recalculated as the two people move in space.
        var theta = getBearingBetweenTwoPoints1(point1: source!, point2: dest!)
        //print(theta) //test out what value theta returns to compare to my hand calculations
        
        /* In this section, I create an empty 4x4 identity matrix that will be used to calculate a rotation matrix for the 3x3 position system of the pyramid's position.
         
        let originTransform = matrix_identity_float4x4
        //I then take theta from before and convert it to radians, pass it into the rotation matrix.
         let radians = GLKMathDegreesToRadians(Float(theta))
         let rotationMatrix = GLKMatrix4MakeYRotation(radians)
         
         //Using the rotation matrix above, I find the matrix with the values for the new positions for x,y,z given the rotation about the y-axis.
         var rotMatrix =  simd_mul(MatrixHelper.convertGLKMatrix4Tosimd_float4x4(rotationMatrix), originTransform)
         //print(rotMatrix[0]) //trying to print values
        */
        //once this is calculates, we create a scene and add the pyramid node. then we load this scene for the useer to see.
        let scene = SCNScene()
        scene.rootNode.addChildNode(pyrNode)
        sceneView.scene = scene

    }

    //functions for converting between degrees and radians
    func degreesToRadians(degrees: Double) -> Double { return degrees * .pi / 180.0 }
    func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / .pi }
    
    //function for calculating the direction of the vector from user location to desired person's location.
    func getBearingBetweenTwoPoints1(point1 : CLLocation, point2 : CLLocation) -> Double {
        
        let lat1 = degreesToRadians(degrees: point1.coordinate.latitude)
        let lon1 = degreesToRadians(degrees: point1.coordinate.longitude)
        
        let lat2 = degreesToRadians(degrees: point2.coordinate.latitude)
        let lon2 = degreesToRadians(degrees: point2.coordinate.longitude)
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        return radiansToDegrees(radians: radiansBearing)
    }
    
   
    //standard part of ARKit app, dictates how the AR view works.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //tracks the world
        let configuration = ARWorldTrackingConfiguration()
        //aligns the world so gravity is down
        configuration.worldAlignment = .gravityAndHeading
        sceneView.session.run(configuration)
    }
    
    //describes how the view will disappear when the app is closed or left in the background
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

//Code from github to help with trying to accomplish the rotation math
struct MatrixHelper {
    
    // GLKMatrix to float4x4
    static func convertGLKMatrix4Tosimd_float4x4(_ matrix: GLKMatrix4) -> float4x4{
        return float4x4(float4(matrix.m00, matrix.m01, matrix.m02, matrix.m03),
                        float4(matrix.m10, matrix.m11, matrix.m12, matrix.m13),
                        float4(matrix.m20, matrix.m21, matrix.m22, matrix.m23),
                        float4(matrix.m30, matrix.m31, matrix.m32, matrix.m33))
    }
    
    // degrees - 0: straight ahead. positive: to the left. negative: to the right
    static func rotateMatrixAroundY(degrees: Float, matrix: simd_float4x4) -> simd_float4x4 {
        let radians = GLKMathDegreesToRadians(degrees)
        let rotationMatrix = GLKMatrix4MakeYRotation(radians)
        return simd_mul(convertGLKMatrix4Tosimd_float4x4(rotationMatrix), matrix)
    }
    
    // degrees - 0: horizon. positive: toward sky. negative: toward ground
    static func translateMatrixFromHorizon(degrees: Float, matrix: simd_float4x4) -> simd_float4x4 {
        
        let radians = GLKMathDegreesToRadians(degrees)
        let horizonMatrix = GLKMatrix4MakeXRotation(radians)
        return simd_mul(convertGLKMatrix4Tosimd_float4x4(horizonMatrix), matrix)
    }
    
    // just what it says on the tin
    static func resetToHorizon(_ matrix: simd_float4x4) -> simd_float4x4 {
        var resultMatrix = matrix
        resultMatrix.columns.3.y = 0
        return resultMatrix
    }
}
