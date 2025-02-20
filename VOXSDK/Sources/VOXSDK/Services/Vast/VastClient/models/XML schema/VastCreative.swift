//
//  VastCreative.swift
//  VastClient
//
//  Created by Jan Bednar on 13/11/2018.
//

import Foundation

struct VastCreativeElements {
    static let universalAdId = "UniversalAdId"
    static let linear = "Linear"
    static let nonLinearAds = "NonLinearAds"
    static let creativeExtension = "CreativeExtension"
    static let companionAds = "CompanionAds"
}

fileprivate enum VastCreativeAttribute: String, CaseIterable {
    case id
    case adId
    case sequence
    case apiFramework
    
    // Vast 2.0 adId tag is "AdID" instead of adId
    init?(rawValue: String) {
        guard let value = VastCreativeAttribute.allCases.first(where: { $0.rawValue.lowercased() == rawValue.lowercased() }) else {
            return nil
        }
        self = value
    }
}

struct VastCreative: Codable {
    let id: String?
    let adId: String?
    let sequence: Int?
    let apiFramework: String?
    
    var universalAdId: VastUniversalAdId?
    var creativeExtensions: [VastCreativeExtension] = []
    var linear: VastLinearCreative?
    var nonLinearAds: VastNonLinearAdsCreative?
    var companionAds: VastCompanionAds?
}

extension VastCreative {
    init(attrDict: [String: String]) {
        var id: String?
        var adId: String?
        var sequence: String?
        var apiFramework: String?
        
        attrDict.compactMap { key, value -> (VastCreativeAttribute, String)? in
            guard let newKey = VastCreativeAttribute(rawValue: key) else {
                return nil
            }
            return (newKey, value)
            }.forEach { (key, value) in
                switch key {
                case .id:
                    id = value
                case .adId:
                    adId = value
                case .sequence:
                    sequence = value
                case .apiFramework:
                    apiFramework = value
                }
        }
        self.id = id
        self.adId = adId
        self.sequence = sequence?.intValue
        self.apiFramework = apiFramework
    }
}

extension VastCreative: Equatable {}
