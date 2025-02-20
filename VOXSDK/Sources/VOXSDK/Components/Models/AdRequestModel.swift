public struct AdRequestModel: Codable {
    public var placeId: String
    public var containerId: String?
    public var browser: BrowserModel?
    public var dspId: String?
    public var adId: String?
    public var additionalInfo: AdRequestAdditionalInfoModel?
    
    // Инициализатор для настройки модели
    public init(placeId: String,
                containerId: String? = nil,
                browser: BrowserModel? = nil,
                dspId: String? = nil,
                adId: String? = nil,
                additionalInfo: AdRequestAdditionalInfoModel? = nil) {
        self.placeId = placeId
        self.containerId = containerId
        self.browser = browser
        self.dspId = dspId
        self.adId = adId
        self.additionalInfo = additionalInfo
    }
}
