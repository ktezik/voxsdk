//
//  VastSurvey.swift
//  VastClient
//
//  Created by Jan Bednar on 12/11/2018.
//

import Foundation

enum VastSurveyAttribute: String {
    case type
}

struct VastSurvey: Codable {
    let type: String?
    
    var survey: URL?
}

extension VastSurvey {
    init(attrDict: [String: String]) {
        var typeValue: String?
        attrDict.compactMap { key, value -> (VastSurveyAttribute, String)? in
            guard let newKey = VastSurveyAttribute(rawValue: key) else {
                return nil
            }
            return (newKey, value)
            }.forEach { (key, value) in
                switch key {
                case .type:
                    typeValue = value
                }
        }
        self.type = typeValue
    }
}

extension VastSurvey: Equatable {
}
