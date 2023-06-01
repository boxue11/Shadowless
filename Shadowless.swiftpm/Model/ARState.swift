//
//  ARState.swift
//  ShadowlessLamp
//
//  Created by Mars on 2023/3/10.
//

import Foundation

enum ARState: Int {
    case detectSurface
    case pointAtSurface
    case tapToStart
    case started
    
    func toString() -> String {
        switch self {
        case .detectSurface:
            return "Scan available flat surfaces..."
        case .pointAtSurface:
            return "Point at designated surface first!"
        case .tapToStart:
            return "Tap to start."
        case .started:
            return "Tap objects for more info."
        }
    }
}
