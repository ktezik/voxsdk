import UIKit

protocol AdCreationService: AnyObject {
    func createBanner(for requestModel: AdRequestModel) async -> UIView?
    func createVASTVideo(
        for requestModel: AdRequestModel,
        in containerView: UIView,
        parentViewController: UIViewController
    ) async
    func showFullScreenBanner(
        for requestModel: AdRequestModel,
        on presentingViewController: UIViewController
    ) async
    
    func update(isShouldHideBannerWithText: Bool)
    func update(closeButtonDelay: TimeInterval)
}
