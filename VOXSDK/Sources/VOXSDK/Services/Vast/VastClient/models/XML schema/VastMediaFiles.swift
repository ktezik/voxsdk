//
//  VastMediaFiles.swift
//  VastClient
//
//  Created by Jan Bednar on 13/11/2018.
//

import Foundation

struct VastMediaFiles: Codable {
    var mediaFiles: [VastMediaFile] = []
    var interactiveCreativeFiles: [VastInteractiveCreativeFile] = []
}

extension VastMediaFiles: Equatable {
}
