enum AdConstants {
    // MARK: - Сообщения для полноэкранного баннера
    static let loadingFullScreenBanner = "🔄 Loading full screen banner ad..."
    static let noContentFullScreenBanner = "❌ No content available for full screen banner ad."
    static let fullScreenBannerPresented = "✅ Full screen banner ad presented."
    static let errorFullScreenBannerPrefix = "❌ Error loading full screen banner ad: "
    
    // MARK: - Сообщения для баннерной рекламы
    static let loadingBannerAd = "🔄 Loading banner ad..."
    static let noContentBannerAd = "❌ No content available for banner ad."
    static let configuringBannerView = "⚙️ Configuring banner view..."
    static let bannerAdCreated = "✅ Banner ad created successfully."
    static let schedulingBannerRefresh = "🔄 Scheduling banner refresh every %.2f seconds."
    static let updatingBannerContent = "🔄 Updating banner with new content."
    static let bannerContentUnchanged = "✅ Banner content unchanged. No update needed."
    static let bannerRefreshTimerInvalidated = "⏹️ Banner refresh timer invalidated."
    
    // MARK: - Сообщения для VAST-видео
    static let loadingVASTVideoAd = "🔄 Loading VAST video ad..."
    static let noVASTContent = "❌ No VAST content available."
    static let parsingVASTFile = "🔄 Parsing VAST file..."
    static let vastParsed = "✅ Parsed VAST model: %@"
    static let vastVideoLoaded = "✅ VAST video ad loaded successfully."
    static let errorVASTVideoAdPrefix = "❌ Failed to load VAST video ad: "
    static let errorParsingVASTPrefix = "❌ Error parsing VAST: "
    
    // MARK: - Сообщения для загрузки данных рекламы
    static let fetchingAdData = "🔄 Fetching ad data from server..."
    static let adDataFetched = "✅ Ad data fetched successfully."
}
