//
//  VastUniversalAdId.swift
//  Nimble
//
//  Created by Jan Bednar on 09/11/2018.
//

import Foundation

enum VastUniversalAdIdAttribute: String {
    case idRegistry
    case idValue
}

struct VastUniversalAdId: Codable {
    let idRegistry: String
    let idValue: String
    
    var uniqueCreativeId: String?
}

extension VastUniversalAdId {
    init?(attrDict: [String: String]) {
        var idRegistry: String?
        var idValue: String?
        attrDict.forEach { key, value in
            guard let attribute = VastUniversalAdIdAttribute(rawValue: key) else {
                return
            }
            switch attribute {
            case .idRegistry:
                idRegistry = value
            case .idValue:
                idValue = value
            }
        }
        guard let registry = idRegistry, let value = idValue else {
            return nil
        }
        self.idRegistry = registry
        self.idValue = value
    }
}

extension VastUniversalAdId: Equatable {
}
