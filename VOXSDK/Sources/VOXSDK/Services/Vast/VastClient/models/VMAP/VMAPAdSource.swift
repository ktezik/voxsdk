//
//  VMAPAdSource.swift
//  VastClient
//
//  Created by John Gainfort Jr on 8/8/18.
//  Copyright © 2018 John Gainfort Jr. All rights reserved.
//

import Foundation

struct VMAPAdSourceElements {
    static let adSource = "vmap:AdSource"
    static let vastAdData = "vmap:VASTAdData"
    static let adTagURI = "vmap:AdTagURI"
    static let customAdData = "vmap:CustomAdData"
}

struct VMAPAdSourceAttributes {
    static let allowMultipleAds = "allowMultipleAds"
    static let followRedirects = "followRedirects"
    static let id = "id"
}

enum VMAPAdSourceTemplate: String, Codable {
    case vast = "vast"
    case vast1 = "vast1"
    case vast2 = "vast2"
    case vast3 = "vast3"
    case vast4 = "vast4"
    case unknown = "unknown"
}

struct VMAPAdSource: Codable {
    let allowMultipleAds: Bool
    let followRedirects: Bool
    let id: String
    var vastAdData: VastModel?
    var adTagURI: URL?
    var customAdData: String?
    var templateType: VMAPAdSourceTemplate?
}

extension VMAPAdSource {
    init(attrDict: [String: String]) {
        var allowMultipleAds = true
        var followRedirects = false
        var id = ""
        for (key, value) in attrDict {
            switch key {
            case VMAPAdSourceAttributes.allowMultipleAds:
                allowMultipleAds = value.lowercased() == "true"
            case VMAPAdSourceAttributes.followRedirects:
                followRedirects = value.lowercased() == "true"
            case VMAPAdSourceAttributes.id:
                id = value
            default:
                break
            }
        }
        self.allowMultipleAds = allowMultipleAds
        self.followRedirects = followRedirects
        self.id = id
    }
}
