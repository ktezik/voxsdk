//
//  VastTrackingEvent.swift
//  VastClient
//
//  Created by John Gainfort Jr on 4/6/18.
//  Copyright © 2018 John Gainfort Jr. All rights reserved.
//

import Foundation

enum TrackingEventType: String, Codable {
    case firstQuartile
    case midpoint
    case thirdQuartile
    case complete
    case creativeView
    case start
    case mute
    case unmute
    case pause
    case rewind
    case resume
    case fullscreen
    case exitFullscreen
    case playerExpand
    case playerCollapse
    case acceptInvitationLinear
    case closeLinear
    case skip
    case progress
    case collapse
    case expand
    case acceptInvitation
    case close
    case unknown
}

struct TrackingEventAttributes {
    static let event = "event"
    static let offset = "offset"
}

struct VastTrackingEvent: Codable {
    let type: TrackingEventType
    let offset: Double?
    
    var url: URL?
    var tracked = false
}

extension VastTrackingEvent {
    init(attrDict: [String: String]) {
        var event = TrackingEventType.unknown
        var offset: Double?
        for (key, value) in attrDict {
            if key == TrackingEventAttributes.event {
                if let evt = TrackingEventType(rawValue: value) {
                    event = evt
                }
            }

            if key == TrackingEventAttributes.offset {
                // format is either (HH:MM:SS or HH:MM:SS.mmm) or n%
                offset = value.firstIndex(of: ":") != nil ? value.toSeconds : Double(value) ?? 0 / 100
            }
        }

        self.type = event
        self.offset = offset
    }
}

extension VastTrackingEvent: Equatable {
}
