//
//  ViewController.swift
//  SCNGeometries-Part2
//
//  Created by Max Cobb on 30/10/2018.
//  Copyright © 2018 Max Cobb. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene

		let light = SCNLight()
		light.type = .omni
		let lightNode = SCNNode()
		lightNode.light = light
		sceneView.pointOfView?.addChildNode(lightNode)

		let newNode = FlagNode(frameSize: CGSize(width: 0.75, height: 0.375), xyCount: CGSize(width: 100, height: 100), diffuse: UIImage(named: "union_jack"))
		//		let newNode = BoxStretch(width: 0.3, height: 0.3, length: 0.3)
		//		let newNode = SCNNode(geometry: SCNGeometry.Plane(width: 0.5, height: 1))
		newNode.position.z = -1
		//		newNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "labyrinth_marker")
		sceneView.scene.rootNode.addChildNode(newNode)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
}
