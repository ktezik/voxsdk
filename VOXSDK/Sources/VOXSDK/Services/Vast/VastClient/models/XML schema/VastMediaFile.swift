//
//  VastMediaFile.swift
//  VastClient
//
//  Created by John Gainfort Jr on 4/6/18.
//  Copyright © 2018 John Gainfort Jr. All rights reserved.
//

import Foundation

fileprivate enum MediaFileAttribute: String {
    case delivery
    case height
    case id
    case type
    case width
    case codec
    case bitrate
    case minBitrate
    case maxBitrate
    case scalable
    case maintainAspectRatio
    case apiFramework
}

struct VastMediaFile: Codable {
    let delivery: String
    let type: String
    let width: String
    let height: String
    let codec: String?
    let id: String?
    let bitrate: Int?
    let minBitrate: Int?
    let maxBitrate: Int?
    let scalable: Bool?
    let maintainAspectRatio: Bool?
    let apiFramework: String?
    
    // content
    var url: URL?
}

extension VastMediaFile {
    init(attrDict: [String: String]) {
        var delivery = ""
        var height = ""
        var id = ""
        var type = ""
        var width = ""
        var codec: String?
        var bitrate: String?
        var minBitrate: String?
        var maxBitrate: String?
        var scalable: String?
        var maintainAspectRatio: String?
        var apiFramework: String?
        
        attrDict.compactMap { key, value -> (MediaFileAttribute, String)? in
            guard let newKey = MediaFileAttribute(rawValue: key) else {
                return nil
            }
            return (newKey, value)
            }.forEach { (key, value) in
                switch key {
                case .delivery:
                    delivery = value
                case .height:
                    height = value
                case .id:
                    id = value
                case .type:
                    type = value
                case .width:
                    width = value
                case .codec:
                    codec = value
                case .bitrate:
                    bitrate = value
                case .minBitrate:
                    minBitrate = value
                case .maxBitrate:
                    maxBitrate = value
                case .scalable:
                    scalable = value
                case .maintainAspectRatio:
                    maintainAspectRatio = value
                case .apiFramework:
                    apiFramework = value
                }
        }
        self.delivery = delivery
        self.height = height
        self.width = width
        self.id = id
        self.type = type
        self.codec = codec
        self.bitrate = bitrate?.intValue
        self.minBitrate = minBitrate?.intValue
        self.maxBitrate = maxBitrate?.intValue
        self.scalable = scalable?.boolValue
        self.maintainAspectRatio = maintainAspectRatio?.boolValue
        self.apiFramework = apiFramework
    }
}

extension VastMediaFile: Equatable {
}
