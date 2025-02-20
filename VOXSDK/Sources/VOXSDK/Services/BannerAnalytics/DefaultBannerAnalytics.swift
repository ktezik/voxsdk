import Foundation

final class DefaultBannerAnalytics {
    
    // MARK: - Private Properties
    private let actionUrls: ActionUrls?
    private let networkService: NetworkSevice
    private let logger = Logger.shared
    
    private var wasLoaded = false
    private var wasShown = false
    private var wasVisible = false
    
    // MARK: - Initializer
    init(
        actionUrls: ActionUrls?,
        networkService: NetworkSevice
    ) {
        self.actionUrls = actionUrls
        self.networkService = networkService
    }
    
}

// MARK: - BannerAlaytics -
extension DefaultBannerAnalytics: BannerAlaytics {
    func loaded() {
        guard !wasLoaded else { return }
        wasLoaded = true
        logger.log("ANALYTICS: Banner loaded")
        let urls = convertString(urls: actionUrls?.loadUrls)
        networkService.sendAnalytics(by: urls, for: "bannerLoaded")
    }
    
    func shown() {
        guard !wasShown else { return }
        wasShown = true
        logger.log("ANALYTICS: Banner was shown")
        let urls = convertString(urls: actionUrls?.impressionUrls)
        networkService.sendAnalytics(by: urls, for: "bannerWasShown")
    }
    
    func visible() {
        guard !wasVisible else { return }
        wasVisible = true
        logger.log("ANALYTICS: Banner visible")
        let urls = convertString(urls: actionUrls?.viewUrls)
        networkService.sendAnalytics(by: urls, for: "bannerVisible")
    }
    
    func click() {
        logger.log("ANALYTICS: Banner click")
        let urls = convertString(urls: actionUrls?.clickUrls)
        networkService.sendAnalytics(by: urls, for: "bannerClick")
    }
    
    func close() {
        logger.log("ANALYTICS: Banner close")
        let urls = convertString(urls: actionUrls?.closeBannerUrls)
        networkService.sendAnalytics(by: urls, for: "bannerClose")
    }
    
}

// MARK: - Private Methods -
private extension DefaultBannerAnalytics {
    func convertString(urls: [String]?) -> [URL] {
        guard let stringUrls = urls, !stringUrls.isEmpty else { return [] }
        return stringUrls.compactMap({ URL(string: $0) })
    }
}
