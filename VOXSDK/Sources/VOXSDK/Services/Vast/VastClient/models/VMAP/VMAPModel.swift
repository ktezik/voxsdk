//
//  VMAPModel.swift
//  VastClient
//
//  Created by John Gainfort Jr on 8/8/18.
//  Copyright © 2018 John Gainfort Jr. All rights reserved.
//

import Foundation

struct VMAPElements {
    static let vmap = "vmap:VMAP"
}

struct VMAPAttributes {
    static let version = "version"
}

struct VMAPModel: Codable {
    let version: String
    var adBreaks = [VMAPAdBreak]()
}

extension VMAPModel {
    init(attrDict: [String: String]) {
        var version = ""
        for (key, value) in attrDict {
            switch key {
            case VMAPAttributes.version:
                version = value
            default:
                break
            }
        }
        self.version = version
    }
}
