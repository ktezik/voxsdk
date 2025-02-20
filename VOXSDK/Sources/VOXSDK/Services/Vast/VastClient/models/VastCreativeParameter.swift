//
//  VastCreativeParameter.swift
//  VastClient
//
//  Created by John Gainfort Jr on 6/5/18.
//  Copyright © 2018 John Gainfort Jr. All rights reserved.
//

import Foundation

// TODO: this is really a custom xml element
// needs to be defined outside of the library
// need to find a way to pass custom elements to the library to use
struct CreativeParameterAttributes {
    static let creativeId = "creativeId"
    static let name = "name"
    static let type = "type"
}

struct VastCreativeParameter: Codable {
    var creativeId: String
    var name: String
    var type: String // TODO: enum
    var content: String?
}

extension VastCreativeParameter {
    init(attrDict: [String: String]) {
        var creativeId = ""
        var name = ""
        var type = ""
        for (key, value) in attrDict {
            switch key {
            case CreativeParameterAttributes.creativeId:
                creativeId = value
            case CreativeParameterAttributes.name:
                name = value
            case CreativeParameterAttributes.type:
                type = value
            default:
                break
            }
        }
        self.creativeId = creativeId
        self.name = name
        self.type = type
    }
}

extension VastCreativeParameter: Equatable {
}


