import Foundation

protocol NetworkSevice {
    func fetchAd(with adRequestModel: AdRequestModel) async throws -> AdModel
    func sendAnalytics(by urls: [URL], for event: String)
}
