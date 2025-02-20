import UIKit

public class VOXAds {
    
    // MARK: - Private Properties
    private static var adService: AdCreationService = DefaultAdCreationService()
    private static var logger = Logger.shared
    
}

// MARK: - Create Banner -
public extension VOXAds {
    /// Создание баннерной рекламы.
    /// - Parameter requestModel: Модель запроса для загрузки рекламы.
    /// - Returns: Обёртка с UIView для отображения рекламы, или nil в случае ошибки.
    @MainActor
    static func createBanner(for requestModel: AdRequestModel) async -> UIView? {
        await adService.createBanner(for: requestModel)
    }
}

// MARK: - Create VAST Video -
public extension VOXAds {
    /// Создание VAST-видео в заданном контейнере.
    /// - Parameters:
    ///   - requestModel: Модель запроса для загрузки рекламы.
    ///   - containerView: Контейнер, в котором будет отображаться видео.
    @MainActor
    static func createVASTVideo(
        for requestModel: AdRequestModel,
        in containerView: UIView,
        parentViewController: UIViewController
    ) async {
        await adService.createVASTVideo(
            for: requestModel,
            in: containerView,
            parentViewController: parentViewController
        )
    }
}

// MARK: - Show Full Screen Banner -
public extension VOXAds {
    /// Создание и показ полноэкранного баннера.
    /// Из модели извлекается только HTML‑контент, который передается в контроллер.
    /// - Parameters:
    ///   - requestModel: Модель запроса для загрузки рекламы.
    ///   - presentingViewController: Контроллер, относительно которого будет показан баннер.
    @MainActor
    static func showFullScreenBanner(
        for requestModel: AdRequestModel,
        on presentingViewController: UIViewController
    ) async {
        await adService.showFullScreenBanner(for: requestModel, on: presentingViewController)
    }
}

// MARK: - Configure SDK -
public extension VOXAds {
    static func configureBannerSettings(
        shouldHideBannerWithText: Bool,
        closeButtonDelay: TimeInterval
    ) {
        adService.update(isShouldHideBannerWithText: shouldHideBannerWithText)
        adService.update(closeButtonDelay: closeButtonDelay)
    }
}
