//
//  VastImpression.swift
//  VastClient
//
//  Created by John Gainfort Jr on 4/6/18.
//  Copyright © 2018 John Gainfort Jr. All rights reserved.
//

import Foundation

struct ImpressionAttributes {
    static let id = "id"
}

struct VastImpression: Codable {
    let id: String?
    
    var url: URL?
}

extension VastImpression {
    init(attrDict: [String: String]) {
        var id: String?
        for (key, value) in attrDict {
            switch key {
            case ImpressionAttributes.id:
                id = value
            default:
                break
            }
        }
        self.id = id
    }
}

extension VastImpression: Equatable {
}
