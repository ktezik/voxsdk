//
//  VastVideoClick.swift
//  VastClient
//
//  Created by John Gainfort Jr on 4/6/18.
//  Copyright © 2018 John Gainfort Jr. All rights reserved.
//

import Foundation

struct VideoClickAttributes {
    static let id = "id"
}

enum ClickType: String, Codable {
    case clickThrough = "ClickThrough" //InLine only
    case clickTracking = "ClickTracking"
    case customClick = "CustomClick"
}

struct VastVideoClick: Codable {
    let id: String?
    let type: ClickType
    
    var url: URL?
}

extension VastVideoClick {
    init(type: ClickType, attrDict: [String: String]) {
        self.type = type
        var id: String?
        for (key, value) in attrDict {
            switch key {
            case VideoClickAttributes.id:
                id = value
            default:
                break
            }
        }
        self.id = id
    }
}

extension VastVideoClick: Equatable {
}
