//
//  ARViewModel.swift
//  ShadowlessLamp
//
//  Created by Mars on 2023/4/6.
//

import SwiftUI
import Combine

class ARViewModel: ObservableObject {
    @Published var arState: ARState = .detectSurface
    @Published var arTrackingStatusText: String = ""
    @Published var numberOfLights: Int = 8
    
    @Published var groundImage: String = "road_gray"
    @Published var cylinderImage: String = "cy_golden_flower"
    @Published var isDisplayCylinder = false
    
    @Published var isDisplayTorus = false
    
    @Published var luminosity: CGFloat = 150
    @Published var isDisplayLights = false
    
    @Published var spotlightsMeta: [SpotlightMeta] = []
    
    var angleStep: Double { Double(2.0 * Double.pi / Double(numberOfLights)) }
    
    init() {
        for i in 0..<numberOfLights {
            spotlightsMeta.append(SpotlightMeta(id: i, luminosity: luminosity, isOn: false))
        }
    }
    
    func reset() {
        groundImage = "road_gray"
        cylinderImage = "cy_golden_flower"
        isDisplayCylinder = false
        isDisplayTorus = false
        luminosity = 150
        isDisplayLights = false
        spotlightsMeta = []
        arState = .tapToStart
        for i in 0..<numberOfLights {
            spotlightsMeta.append(SpotlightMeta(id: i, luminosity: luminosity, isOn: false))
        }
    }
}
