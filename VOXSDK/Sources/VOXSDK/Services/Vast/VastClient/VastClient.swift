//
//  VastClient.swift
//  VastClient
//
//  Created by John Gainfort Jr on 4/6/18.
//  Copyright © 2018 John Gainfort Jr. All rights reserved.
//

import Foundation

struct VastClientOptions {
    let wrapperLimit: Int
    let singleWrapperTimeLimit: TimeInterval
    let timeLimit: TimeInterval
    let cachedVMAPModel: VMAPModel?

    init(wrapperLimit: Int = 5, singleWrapperTimeLimit: TimeInterval = 5, timeLimit: TimeInterval = 10, cachedVMAPModel: VMAPModel? = nil) {
        self.wrapperLimit = wrapperLimit
        self.singleWrapperTimeLimit = singleWrapperTimeLimit
        self.timeLimit = timeLimit
        self.cachedVMAPModel = cachedVMAPModel
    }
}

class VastClient {
    
    static var trackingLogOutput: ((String, [URL]) -> ())? = nil

    private let options: VastClientOptions

    init(options: VastClientOptions = VastClientOptions()) {
        self.options = options
    }
    
    func parseVast(withContentsOf url: URL, completion: @escaping (VastModel?, Error?) -> ()) {
        let parser = VastParser(options: options)
        parser.parse(url: url, completion: completion)
    }
    
    func parseVMAP(withContentsOf url: URL) throws -> VMAPModel {
        let parser = VMAPParser(options: options)
        return try parser.parse(url: url)
    }
    
    
    /**
     Load local files easily with schema specifier "test://"
     
     Use this to chain wrapper parsers to be forced to used local path from VastAdTagURI. Make sure to change all VastAdTagURI to local test path.
     
     - parameter url: URL of local or remote file. For local files the url has to start with `test://` and can not contain ".xml" extension. For example: `test://Pubads_Inline_Model-test` to load file named "Pubads_Inline_Model-test.xml"
     - parameter testbundle: bundle of the test that contains local test xml files
     */
    func parseVast(withContentsOf url: URL, testBundle: Bundle, completion: @escaping (VastModel?, Error?) -> ()) {
        let parser = VastParser(options: options, testFileBundle: testBundle)
        parser.parse(url: url, completion: completion)
    }
}
