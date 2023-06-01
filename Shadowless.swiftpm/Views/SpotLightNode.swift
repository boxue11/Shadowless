//
//  SpotLightNode.swift
//  ShadowlessLamp
//
//  Created by Mars on 2023/4/10.
//

import SceneKit

class SpotlightMeta {
    let id: Int
    var luminosity: CGFloat
    var isOn: Bool
    var isDisplay = false
    
    init(id: Int, luminosity: CGFloat, isOn: Bool) {
        self.id = id
        self.luminosity = luminosity
        self.isOn = isOn
    }
}

class SpotlightNode {
    let id: Int
    let model: SCNNode
    let light: SCNNode
    
    init(id: Int, model: SCNNode, light: SCNNode) {
        self.id = id
        self.model = model
        self.light = light
    }
    
    func setLuminosity(_ intensity: CGFloat) {
        light.light?.intensity = intensity
    }
    
    func turnOn(color: UIColor = UIColor.yellow) {
        if let sphereNode = model.childNode(withName: "sphere", recursively: false) {
            let material = SCNMaterial()
            material.diffuse.contents = color
            
            sphereNode.geometry?.materials = [material]
            sphereNode.geometry?.firstMaterial?.lightingModel = .physicallyBased
            
            light.isHidden = false
        }
    }
    
    func turnOff() {
        if let sphereNode = model.childNode(withName: "sphere", recursively: false) {
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.lightGray
            sphereNode.geometry?.materials = [material]
            sphereNode.geometry?.firstMaterial?.lightingModel = .physicallyBased
            
            light.isHidden = true
        }
    }
}
