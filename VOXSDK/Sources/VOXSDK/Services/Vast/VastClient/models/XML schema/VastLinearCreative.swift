//
//  VastLinearCreative.swift
//  VastClient
//
//  Created by John Gainfort Jr on 4/6/18.
//  Copyright © 2018 John Gainfort Jr. All rights reserved.
//

import Foundation

struct CreativeLinearElements {
    static let duration = "Duration"
    static let adParameters = "AdParameters"

    // /MediaFiles
    static let mediafile = "MediaFile"
    static let interactiveCreativeFile = "InteractiveCreativeFile"
    
    // /VideoClicks
    static let clickthrough = "ClickThrough"
    static let clicktracking = "ClickTracking"
    static let customclick = "CustomClick"
    
    static let trackingEvents = "TrackingEvents"
    static let tracking = "Tracking"
    
    // /Icons
    static let icon = "Icon"
}

fileprivate enum LinearCreativeAttribute: String, CaseIterable {
    case skipoffset
    
    init?(rawValue: String) {
        guard let value = LinearCreativeAttribute.allCases.first(where: { $0.rawValue.lowercased() == rawValue.lowercased() }) else {
            return nil
        }
        self = value
    }
}

// VAST/Ad/InLine/Creatives/Creative
// VAST/Ad/Wrapper/Creatives/Creative
struct VastLinearCreative: Codable {
    let skipOffset: String? // TODO: Consider changing to Int
    
    var duration: Double? // Inline only
    var adParameters: VastAdParameters? // Inline only
    var videoClicks: [VastVideoClick] = []
    var trackingEvents: [VastTrackingEvent] = []
    var files = VastMediaFiles()
    var icons = [VastIcon]()
}

extension VastLinearCreative {
    init(attrDict: [String: String]) {
        var skipOffset: String?
        attrDict.compactMap { key, value -> (LinearCreativeAttribute, String)? in
            guard let newKey = LinearCreativeAttribute(rawValue: key) else {
                return nil
            }
            return (newKey, value)
            }.forEach { (key, value) in
                switch key {
                case .skipoffset:
                    skipOffset = value
                }
        }
        self.skipOffset = skipOffset
    }
}

extension VastLinearCreative: Equatable {
}
