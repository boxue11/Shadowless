//
//  ARViewController.swift
//  ShadowlessLamp
//
//  Created by Mars on 2023/3/15.
//

import ARKit
import SceneKit
import SwiftUI
import RealityKit
import Combine


struct ARVC: UIViewControllerRepresentable {
    var model: ARViewModel
    
    func makeUIViewController(context: Context) -> ARViewController {
        let arVC = ARViewController(model: model)
        return arVC
    }
    
    func updateUIViewController(_ uiViewController: ARViewController, context: Context) {
        
    }
}

class ARViewController: UIViewController {
    var model: ARViewModel
    
    var focusPoint: CGPoint!
    
    var focusNode: SCNNode!
    var pgRootNode: SCNNode!
    
    var groundNode: SCNNode!
    var cylinderNode: SCNNode!
    
    var torusNode: SCNNode!
    
    var arSceneView: ARSCNView!
    
    var spotlights: [SpotlightNode] = []
    
    init(model: ARViewModel) {
        self.model = model
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ARViewController.handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        
        initCoachingOverlayView()
        initARSession()
        
        initFocusNode()
        
        model.$groundImage.sink(receiveValue: { imgName in
            print("Updating ground image.")
            self.setGroundMaterial(imgName)
        }).store(in: &subscriptions)
        
        model.$cylinderImage.sink(receiveValue: { imgName in
            print("Updating cylinder image.")
            self.setCylinderMaterial(imgName)
        }).store(in: &subscriptions)
        
        model.$isDisplayCylinder.sink(receiveValue: {
            print("Toggle cylinder display.")
            self.cylinderNode.isHidden = !$0
        }).store(in: &subscriptions)
        
        model.$isDisplayTorus.sink(receiveValue: {
            print("Toggle torus display.")
            self.torusNode.isHidden = !$0
        }).store(in: &subscriptions)
        
        model.$isDisplayLights.sink(receiveValue: {
            print("Toggle light models display")
            for light in self.spotlights {
                light.model.isHidden = !$0
            }
        }).store(in: &subscriptions)
        
        model.$luminosity.sink(receiveValue: { l in
            for light in self.spotlights {
                light.setLuminosity(l)
            }
        }).store(in: &subscriptions)
        
        model.$spotlightsMeta.sink(receiveValue: { metas in
            print("Toggle light display")
            for i in 0..<metas.count {
                if metas[i].isOn {
                    self.spotlights[i].turnOn()
                }
                else {
                    self.spotlights[i].turnOff()
                }
                
            }
        }).store(in: &subscriptions)
    }
    
    override func loadView() {
        initScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("[ARViewController]: ARViewController will appear.")
        
        focusPoint = CGPoint(x: view.center.x, y: view.center.y * 1.1)
        
#if DEBUG
        print("[ARViewController]: Focus point is: \(focusPoint ?? CGPoint.zero).")
#endif
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("[ARViewController]: ARViewController will disappear.")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("[ARViewController]: Insufficient memory.")
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension ARViewController {
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        guard model.arState == .tapToStart else {
            return
        }
        
        pgRootNode.isHidden = false
        focusNode.isHidden = true
        
        pgRootNode.position = focusNode.position
        
        DispatchQueue.main.async {
            self.model.arState = .started
        }
        
        
#if DEBUG
        print("[ARViewController]: ARState: \(model.arState).")
#endif
    }
    
    @objc func initFocusNode() {
        let focusScene = SCNScene(named: "Focus.scn")!
        focusNode = focusScene.rootNode.childNode(withName: "Focus", recursively: false)!
        
        focusNode.isHidden = true
        arSceneView.scene.rootNode.addChildNode(focusNode)
        
        focusPoint = CGPoint(x: view.center.x, y: view.center.y * 1.1)
        
#if DEBUG
        print("[ARViewController]: Focus point is: \(focusPoint ?? CGPoint.zero).")
#endif
    }
    
    func updateFocusNode() {
        guard model.arState != .started else {
            focusNode.isHidden = true
            return
        }
        
        let query = arSceneView.raycastQuery(
            from: focusPoint,
            allowing: .estimatedPlane,
            alignment: .horizontal
        )
        
        if let query = query {
            let results = arSceneView.session.raycast(query)
            
            if results.count == 1, let match = results.first {
                let t = match.worldTransform
                focusNode.position = SCNVector3(
                    x: t.columns.3.x,
                    y: t.columns.3.y,
                    z: t.columns.3.z
                )
                
                DispatchQueue.main.async {
                    self.model.arState = .tapToStart
                }
                
                focusNode.isHidden = false
            }
            else {
                DispatchQueue.main.async {
                    self.model.arState = .pointAtSurface
                }
                
                focusNode.isHidden = true
            }
        }
    }
    
    override func viewWillTransition(
        to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            super.viewWillTransition(to: size, with: coordinator)
            
            focusPoint = CGPoint(x: size.width / 2, y: size.height / 2 * 1.1)
            
#if DEBUG
            print("[ARViewController]: Focus point changed to: \(focusPoint ?? CGPoint.zero).")
#endif
        }
}

// MARK: - AR scene view delegate
/**
 * SCNSceneRendererDelegate, ARSessionObserver
 *               |            |
 *               v            v
 *              ARSCNViewDelegate
 */
extension ARViewController: ARSCNViewDelegate {
    // SCNSceneRendererDelegate
    // Call before displaying each frame.
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        updateFocusNode()
    }
    
    // ARSessionObserver
    // ARSession has stopped running due to an error.
    func session(_ session: ARSession, didFailWithError error: Error) {
        model.arTrackingStatusText = "[ARViewController]: AR Session has stopped due to: \(error)."
        
#if DEBUG
        print("[ARViewController]: \(model.arTrackingStatusText).")
#endif
    }
    
    // ARSessionObserver
    // ARSession has temporarily stopped processing frames and tracking device position.
    func sessionWasInterrupted(_ session: ARSession) {
        model.arTrackingStatusText = "[ARViewController]: AR Session was Interrupted."
        
#if DEBUG
        print("[ARViewController]: \(model.arTrackingStatusText).")
#endif
    }
    
    // ARSessionObserver
    // ARSession has resumed processing frames and tracking device position.
    func sessionInterruptionEnded(_ session: ARSession) {
        model.arTrackingStatusText = "[ARViewController]: AR Session interruption ended."
        
#if DEBUG
        print("[ARViewController]: \(model.arTrackingStatusText).")
#endif
    }
    
    // ARSessionObserver
    // The quality of ARKit's device position tracking was changed.
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .notAvailable:
            model.arTrackingStatusText = "[ARViewController]: Tracking: Not available!"
        case .normal:
            model.arTrackingStatusText = "[ARViewController]: Tracking: Normal."
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                model.arTrackingStatusText = "[ARViewController]: Tracking: Limited due to excessive motion!"
            case .insufficientFeatures:
                model.arTrackingStatusText = "[ARViewController]: Tracking: Limited due to insufficient features!"
            case .relocalizing:
                model.arTrackingStatusText = "[ARViewController]: Tracking: Relocalizing..."
            case .initializing:
                model.arTrackingStatusText = "[ARViewController]: Tracking: Initializing..."
            @unknown default:
                model.arTrackingStatusText = "[ARViewController]: Tracking: Unknown error."
            }
        }
        
#if DEBUG
        print("[ARViewController]: \(model.arTrackingStatusText).")
#endif
    }
}

// MARK: - AR coaching overlay
extension ARViewController: ARCoachingOverlayViewDelegate {
    func initCoachingOverlayView() {
        let overlay = ARCoachingOverlayView()
        
        overlay.session = arSceneView.session
        overlay.delegate = self
        overlay.activatesAutomatically = true
        overlay.goal = .horizontalPlane
        
        arSceneView.addSubview(overlay)
        
        overlay.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(
                item: overlay, attribute: .top, relatedBy: .equal,
                toItem: arSceneView, attribute: .top, multiplier: 1, constant: 0
            ),
            NSLayoutConstraint(
                item: overlay, attribute: .bottom, relatedBy: .equal,
                toItem: arSceneView, attribute: .bottom, multiplier: 1, constant: 0
            ),
            NSLayoutConstraint(
                item: overlay, attribute: .leading, relatedBy: .equal,
                toItem: arSceneView, attribute: .leading, multiplier: 1, constant: 0
            ),
            NSLayoutConstraint(
                item: overlay, attribute: .trailing, relatedBy: .equal,
                toItem: arSceneView, attribute: .trailing, multiplier: 1, constant: 0
            )
        ])
    }
    
    func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
#if DEBUG
        print("[ARViewController]: Coaching overlay will activate to help you finding an AR anchor.")
#endif
    }
    
    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
#if DEBUG
        print("[ARViewController]: Find an anchor successfully. Coaching overlay will deactivate.")
#endif
    }
    
    func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
#if DEBUG
        print("[ARViewController]: Environment changed. Reset AR session.")
#endif
    }
}

// MARK: - Scene management
extension ARViewController {
    func deepCopyNode(_ node: SCNNode) -> SCNNode {
        
        // internal function for recurrsive calls
        func deepCopyInternals(_ node: SCNNode) {
            node.geometry = node.geometry?.copy() as? SCNGeometry
            if let g = node.geometry {
                node.geometry?.materials = g.materials.map { $0.copy() as! SCNMaterial }
            }
            for child in node.childNodes {
                deepCopyInternals(child)
            }
        }
        
        // CLONE main node (and all kids)
        // issue here is that both geometry and materials are linked
        // still. In our deepCopyNode we want new copies of everything
        let clone = node.clone()
        
        // we use this internal function to update both
        // geometry and materials, as well as process all children
        // this is the *deep* part of "deepCopy"
        deepCopyInternals(clone)
        
        return clone
    }
    
    func initScene() {
        arSceneView = ARSCNView(frame: .zero)
        
        let scene = SCNScene()
        arSceneView.scene = scene
        arSceneView.delegate = self
        
        let playgroundSCN = SCNScene(named: "Playground.scn")!
        
        pgRootNode = playgroundSCN.rootNode.childNode(withName: "Root", recursively: false)!
        pgRootNode.castsShadow = false
        pgRootNode.isHidden = true
        
        groundNode = pgRootNode.childNode(withName: "Ground", recursively: false)!
        cylinderNode = pgRootNode.childNode(withName: "Cylinder", recursively: false)!
        cylinderNode.isHidden = !model.isDisplayCylinder
        
        torusNode = pgRootNode.childNode(withName: "Torus", recursively: false)!
        torusNode.isHidden = !model.isDisplayTorus
        
        let angleStep = Double(2.0 * Double.pi / Double(model.numberOfLights))
        let r = 1.0
        
        for i in 0..<model.spotlightsMeta.count {
            let pos = SCNVector3(r * sin(angleStep * Double(i)), 1.2, r * cos(angleStep * Double(i)))
            let spotlight = createSpotLight(
                id: i,
                isOn: model.spotlightsMeta[i].isOn,
                luminosity: model.spotlightsMeta[i].luminosity,
                pos: pos,
                target: cylinderNode
            )
            
            spotlights.append(spotlight)
            
            pgRootNode.addChildNode(spotlight.model)
            pgRootNode.addChildNode(spotlight.light)
        }
        
        pgRootNode.scale = SCNVector3(0.3, 0.3, 0.3)
        
        arSceneView.scene.rootNode.addChildNode(pgRootNode)
        self.view = arSceneView
        
#if DEBUG
        arSceneView.showsStatistics = true
        //    arSceneView.debugOptions = [
        //      ARSCNDebugOptions.showFeaturePoints,
        //      ARSCNDebugOptions.showWorldOrigin,
        //      SCNDebugOptions.showBoundingBoxes,
        //      SCNDebugOptions.showWireframe
        //    ]
#endif
    }
}

// MARK: - AR session management
extension ARViewController {
    func initARSession() {
        guard ARWorldTrackingConfiguration.isSupported else {
            print("** ARConfig: AR World Tracking is not supported on this device!! **")
            return
        }
        
        let config = ARWorldTrackingConfiguration()
        config.worldAlignment = .gravity
        config.providesAudioData = false
        config.planeDetection = .horizontal
        config.isLightEstimationEnabled = true
        config.environmentTexturing = .automatic
        
        arSceneView.session.run(config)
    }
    
    func resetARSession(sceneView: ARSCNView) {
        let config = sceneView.session.configuration as!
        ARWorldTrackingConfiguration
        config.planeDetection = .horizontal
        arSceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
}

extension ARViewController {
    func setGroundMaterial(_ name: String) {
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: name)
        
        groundNode.geometry?.materials = [material]
    }
    
    func setCylinderMaterial(_ name: String) {
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: name)
        
        cylinderNode.geometry?.materials = [material]
    }
    
    func createSpotLight(id: Int, isOn: Bool, luminosity: CGFloat, pos: SCNVector3, target: SCNNode) -> SpotlightNode {
        let playgroundSCN = SCNScene(named: "Playground.scn")!
        let spotlightNode = playgroundSCN.rootNode.childNode(withName: "Spotlight", recursively: false)!
        
        // The model
        let sp = deepCopyNode(spotlightNode)
        sp.position = pos
        sp.isHidden = !model.isDisplayLights
        
        let constraint = SCNLookAtConstraint(target: target)
        constraint.localFront = SCNVector3(x: 0, y: -1, z: 0)
        sp.constraints = [constraint]
        
        // The light
        let lightNode = SCNNode()
        let light = SCNLight()
        light.castsShadow = true
        light.type = .directional
        light.color = UIColor.white
        light.intensity = luminosity
        light.shadowMode = .forward
        
        lightNode.light = light
        lightNode.position = pos
        lightNode.position.y += 0.3
        
        let lookAtConstraint = SCNLookAtConstraint(target: cylinderNode)
        lightNode.constraints = [lookAtConstraint]
        
        let ret = SpotlightNode(id: id, model: sp, light: lightNode)
        
        if !isOn {
            ret.turnOff()
        }
        else {
            ret.turnOn()
        }
        
        return ret
    }
}
