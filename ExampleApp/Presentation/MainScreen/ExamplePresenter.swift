import UIKit
import VOXSDK

final class ExamplePresenter {
    
    // MARK: - Public Properties
    weak var view: ExampleView?
    
    // MARK: - Initializer
    init(view: ExampleView) {
        self.view = view
    }
    
    // MARK: - Public Methods
    func confiAD() {
        VOXAds.configureBannerSettings(
            shouldHideBannerWithText: false,
            closeButtonDelay: 5.0
        )
    }
    
    func getAd(for placeId: String) {
        Task { @MainActor in
            let requestModel = AdRequestModel(placeId: placeId)
            if let bannerView = await VOXAds.createBanner(for: requestModel) {
                self.view?.displayBanner(bannerView)
            } else {
                print("Ошибка при загрузке баннера")
            }
        }
    }
    
    func presentAd(for placeId: String, vc: UIViewController) {
        Task { @MainActor in
            let requestModel = AdRequestModel(placeId: placeId)
            await VOXAds.showFullScreenBanner(for: requestModel, on: vc)
        }
    }
    
    func getVideoAd(for placeId: String, in view: UIView, vc: UIViewController) {
        Task { @MainActor in
            let requestModel = AdRequestModel(placeId: placeId)
            await VOXAds.createVASTVideo(for: requestModel, in: view, parentViewController: vc)
        }
    }
}
