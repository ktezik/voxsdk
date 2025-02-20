enum IgnoredTrackerType: String, CaseIterable {
    case create = "CREATIVEVIEW"
    case progress = "PROGRESS"
    case impressions = "IMPRESSIONS"
}

extension IgnoredTrackerType {
    static func contains(rawValue: String) -> Bool {
        IgnoredTrackerType(rawValue: rawValue) != nil
    }
}
