//
//  VastCompanionCreative.swift
//  VastClient
//
//  Created by John Gainfort Jr on 6/6/18.
//  Copyright © 2018 John Gainfort Jr. All rights reserved.
//

import Foundation

struct CompanionElements {
    static let alttext = "AltText"
    static let companionclickthrough = "CompanionClickThrough"
    static let companionclicktracking = "CompanionClickTracking"
    static let trackingevents = "TrackingEvents"
    static let adparameters = "adparameters"
    static let htmlResource = "HTMLResource"
    static let iframeResource = "IFrameResource"
    static let staticResource = "StaticResource"
}

struct CompanionAttributes {
    static let width = "width"
    static let height = "height"
    static let id = "id"
    static let assetwidth = "assetWidth"
    static let assetheight = "assetHeight"
    static let expandedwidth = "expandedWidth"
    static let expandedheight = "expandedHeight"
    static let apiframework = "apiFramework"
    static let adslotid = "adSlotId" //vast 3
    static let adslotid4 = "adSlotID" //vast 4
    static let pxRatio = "pxratio"
}

struct VastCompanionClickTracking {
    let id: String?
}

struct VastCompanionCreative: Codable {
    // Attributes
    let width: Int
    let height: Int
    let id: String?
    let assetWidth: Int?
    let assetHeight: Int?
    let expandedWidth: Int?
    let expandedHeight: Int?
    let apiFramework: String?
    let adSlotId: String?
    let pxRatio: Double?
    
    // Sub Elements
    var staticResource: [VastStaticResource] = []
    var iFrameResource: [URL] = []
    var htmlResource: [URL] = []
    var altText: String?
    var companionClickThrough: URL?
    var companionClickTracking: [URL] = []
    var trackingEvents: [VastTrackingEvent] = []
    var adParameters: VastAdParameters?
}

extension VastCompanionCreative {
    init(attrDict: [String: String]) {
        var width = 0
        var height = 0
        var id: String?
        var assetWidth: Int?
        var assetHeight: Int?
        var expandedWidth: Int?
        var expandedHeight: Int?
        var apiFramework: String?
        var adSlotId: String?
        var pxRatio: Double?

        for (key, value) in attrDict {
            switch key {
            case CompanionAttributes.width:
                width = Int(value) ?? 0
            case CompanionAttributes.height:
                height = Int(value) ?? 0
            case CompanionAttributes.id:
                id = value
            case CompanionAttributes.assetwidth:
                assetWidth = Int(value)
            case CompanionAttributes.assetheight:
                assetHeight = Int(value)
            case CompanionAttributes.expandedwidth:
                expandedWidth = Int(value)
            case CompanionAttributes.expandedheight:
                expandedHeight = Int(value)
            case CompanionAttributes.apiframework:
                apiFramework = value
            case CompanionAttributes.adslotid, CompanionAttributes.adslotid4:
                adSlotId = value
            case CompanionAttributes.pxRatio:
                pxRatio = Double(value)
            default:
                break
            }
        }

        self.width = width
        self.height = height
        self.id = id
        self.assetWidth = assetWidth
        self.assetHeight = assetHeight
        self.expandedWidth = expandedWidth
        self.expandedHeight = expandedHeight
        self.apiFramework = apiFramework
        self.adSlotId = adSlotId
        self.pxRatio = pxRatio
    }
}

extension VastCompanionCreative: Equatable {}
