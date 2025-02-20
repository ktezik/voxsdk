public struct AdModel: Codable {
    var placeId: String
    var seanceId: String?
    var bidId: String?
    var containerId: String?
    var content: String?
    var width: Int?
    var height: Int?
    var isStretchableInWidth: Bool?
    var isStretchableInHeight: Bool?
    var actionUrls: ActionUrls?
    var isPassback: Bool?
    var isDomonetization: Bool?
    var adNet: String?
    var adId: String?
    var erid: String?
    var isRu: Bool?
    var isCloseButtonEnabled: Bool?
    var showMultipleAds: Bool?
    var nextAdInSeconds: Int?
    var inImageOptions: InImageOptions?
}
