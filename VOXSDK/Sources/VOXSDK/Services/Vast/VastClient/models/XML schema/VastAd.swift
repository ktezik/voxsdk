//
//  VastAd.swift
//  VastClient
//
//  Created by John Gainfort Jr on 4/6/18.
//  Copyright © 2018 John Gainfort Jr. All rights reserved.
//

import Foundation

struct AdElements {
    static let wrapper = "Wrapper"
    static let inLine = "InLine"
    
    static let adSystem = "AdSystem"
    static let adTitle = "AdTitle"
    static let description = "Description"
    static let error = "Error"
    
    static let impression = "Impression"
    static let category = "Category"
    static let advertiser = "Advertiser"
    static let pricing = "Pricing"
    static let survey = "Survey"
    static let viewableImpression = "ViewableImpression"
    static let verification = "Verification"
    
    static let creatives = "Creatives"
    static let creative = "Creative"
    
    static let extensions = "Extensions"
    static let ext = "Extension"
}

struct AdAttributes {
    static let id = "id"
    static let sequence = "sequence"
    static let conditionalAd = "conditionalAd"
}

enum AdType: String, Codable {
    case inline
    case wrapper
    case unknown
}

struct VastAd: Codable {
    // Non element type
    var type: AdType
    
    // attribute
    let id: String
    let sequence: Int?
    let conditionalAd: Bool?
    
    // VAST/Ad/Wrapper and VAST/Ad/InLine elements
    var adSystem: VastAdSystem?
    var impressions: [VastImpression] = []
    var adVerifications: [VastVerification] = []
    var viewableImpression: VastViewableImpression?
    var pricing: VastPricing?
    var errors: [URL] = []
    var creatives: [VastCreative] = []
    var extensions: [VastExtension] = []
    
    // Inline only
    var adTitle: String?
    var adCategories: [VastAdCategory] = []
    var description: String?
    var advertiser: String?
    var surveys: [VastSurvey] = []
    
    var wrapper: VastWrapper?
}

extension VastAd {
    init(attrDict: [String: String]) {
        var id = ""
        var sequence = ""
        var conditionalAd = ""
        for (key, value) in attrDict {
            switch key {
            case AdAttributes.id:
                id = value
            case AdAttributes.sequence:
                sequence = value
            case AdAttributes.conditionalAd:
                conditionalAd = value
            default:
                break
            }
        }
        self.id = id
        self.sequence = Int(sequence)
        self.conditionalAd = conditionalAd.boolValue
        self.type = .unknown
    }
}

extension VastAd: Equatable {
}
