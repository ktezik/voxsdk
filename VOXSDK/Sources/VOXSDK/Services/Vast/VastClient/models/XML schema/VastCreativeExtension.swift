//
//  VastCreativeExtension.swift
//  Nimble
//
//  Created by Jan Bednar on 09/11/2018.
//

import Foundation

enum VastCreativeExtensionAttribute: String {
    case type
}

struct VastCreativeExtension: Codable {
    let mimeType: String?
    
    var content: String? //XML
}

extension VastCreativeExtension {
    init?(attrDict: [String: String]) {
        var type: String?
        attrDict.forEach({ key, value in
            guard let attribute = VastCreativeExtensionAttribute(rawValue: key) else {
                return
            }
            switch attribute {
            case .type:
                type = value
            }
        })
        self.mimeType = type
    }
}

extension VastCreativeExtension: Equatable {
}
