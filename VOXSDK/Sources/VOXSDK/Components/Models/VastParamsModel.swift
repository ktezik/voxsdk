public struct VastParamsModel: Codable {
    public let url: String
    public let protocols: [VideoProtocolEnum]
    public let size: String
    public let mimes: [String]
    public let minDur: Int
    public let maxDur: Int
    public let minBtr: Int
    public let maxBtr: Int
    public let pb: String
    public let viFormat: VideoInventoryFormatEnum
    public let api: [ApiFrameworkEnum]
    public let skippable: SkippableEnum
}
