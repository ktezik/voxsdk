//
//  VastIcon.swift
//  VastClient
//
//  Created by Jan Bednar on 09/11/2018.
//

import Foundation

struct VastIconElements {
    static let staticResource = "StaticResource"
    static let iFrameResource = "IFrameResource"
    static let htmlResource = "HTMLResource"
    static let iconClicks = "IconClicks"
    static let iconViewTracking = "IconViewTracking"
}

enum VastIconAttribute: String {
    case program
    case width
    case height
    case xPosition
    case yPosition
    case duration
    case offset
    case apiFramework
    case pxratio
}

struct VastIcon: Codable {
    let program: String
    let width: Int
    let height: Int
    let xPosition: String //([0-9]*|left|right)
    let yPosition: String //([0-9]*|top|bottom)
    let duration: Double
    let offset: Double
    let apiFramework: String
    let pxratio: Double
    
    var iconViewTracking: [URL] = []
    var iconClicks: IconClicks?
    var staticResource: [VastStaticResource] = []
}

extension VastIcon {
    init(attrDict: [String: String]) {
        var program = ""
        var width = ""
        var height = ""
        var xPosition = ""
        var yPosition = ""
        var duration = ""
        var offset = ""
        var apiFramework = ""
        var pxratio = ""
        attrDict.compactMap( {key, value -> (VastIconAttribute, String)? in
            guard let newKey = VastIconAttribute(rawValue: key) else {
                return nil
            }
            return (newKey, value)
        }).forEach { (key, value) in
            switch key {
            case .program:
                program = value
            case .width:
                width = value
            case .height:
                height = value
            case .xPosition:
                xPosition = value
            case .yPosition:
                yPosition = value
            case .duration:
                duration  = value
            case .offset:
                offset  = value
            case .apiFramework:
                apiFramework = value
            case .pxratio:
                pxratio = value
            }
        }
        
        self.program = program
        self.width = width.intValue ?? 0
        self.height = height.intValue ?? 0
        self.xPosition = xPosition
        self.yPosition = yPosition
        self.duration = duration.toSeconds ?? 0
        self.offset = offset.toSeconds ?? 0
        self.apiFramework = apiFramework
        self.pxratio = pxratio.doubleValue ?? 1
    }
}

extension VastIcon: Equatable {
}
