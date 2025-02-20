import UIKit

final class DefaultAdCreationService {
    
    // MARK: - Private Properties
    private let logger = Logger.shared
    private let vastService: VastService = DefaultVastService()
    private let networkService: NetworkSevice = DefaultNetworkService()
    
    // Использование статического таймера ограничивает обновление только одним баннером.
    // Если предполагается поддержка нескольких баннеров, следует пересмотреть архитектуру.
    private var bannerTimer: Timer?
    
    private var isShouldHideBannerWithText = true
    private var closeButtonDelay: TimeInterval = 0.0
    
}

// MARK: - AdCreationService -
extension DefaultAdCreationService: AdCreationService {
    @MainActor
    func createBanner(for requestModel: AdRequestModel) async -> UIView? {
        do {
            logger.log(AdConstants.loadingBannerAd)
            let adModel = try await fetchAdData(for: requestModel)
            
            guard let content = adModel.content else {
                logger.log(AdConstants.noContentBannerAd)
                return nil
            }
            
            logger.log(AdConstants.configuringBannerView)
            let bannerView = configureBannerView(with: adModel, content: content)
            
            // Если баннер предназначен для автоподмены, запускаем таймер обновления.
            if shouldAutoRefreshBanner(adModel), let interval = adModel.nextAdInSeconds {
                scheduleBannerRefresh(for: bannerView,
                                      interval: TimeInterval(interval),
                                      requestModel: requestModel,
                                      previousAdModel: adModel)
            } else {
                invalidateBannerTimer()
            }
            
            return bannerView
            
        } catch {
            logger.log("❌ Failed to load banner ad: \(error.localizedDescription)")
            return nil
        }
    }
    
    @MainActor
    func createVASTVideo(for requestModel: AdRequestModel,
                         in containerView: UIView,
                         parentViewController: UIViewController) async {
        do {
            logger.log(AdConstants.loadingVASTVideoAd)
            let adModel = try await fetchAdData(for: requestModel)
            guard let vastContent = adModel.content else {
                logger.log(AdConstants.noVASTContent)
                return
            }
            
            let vastUrl = try vastService.saveXMLToFile(xmlString: vastContent, fileName: "Video")
            await loadVASTVideo(from: vastUrl,
                                in: containerView,
                                parentViewController: parentViewController)
            
        } catch {
            logger.log(AdConstants.errorVASTVideoAdPrefix + error.localizedDescription)
        }
    }
    
    @MainActor
    func showFullScreenBanner(
        for requestModel: AdRequestModel,
        on presentingViewController: UIViewController
    ) async {
        do {
            logger.log(AdConstants.loadingFullScreenBanner)
            let adModel = try await fetchAdData(for: requestModel)
            
            guard let content = adModel.content else {
                logger.log(AdConstants.noContentFullScreenBanner)
                return
            }
            
            let analytics = DefaultBannerAnalytics(
                actionUrls: adModel.actionUrls,
                networkService: networkService
            )
            
            // Создаем контроллер, который принимает HTML-контент для полноэкранного отображения.
            let fullScreenVC = FullScreenBannerViewController(
                analytics: analytics,
                htmlContent: content,
                closeButtonDelay: getCloseButtonDelay()
            )
            fullScreenVC.modalPresentationStyle = .fullScreen
            fullScreenVC.modalTransitionStyle = .crossDissolve
            presentingViewController.present(fullScreenVC, animated: true, completion: nil)
            
            logger.log(AdConstants.fullScreenBannerPresented)
        } catch {
            logger.log(AdConstants.errorFullScreenBannerPrefix + error.localizedDescription)
        }
    }
    
    func update(isShouldHideBannerWithText: Bool) {
        self.isShouldHideBannerWithText = isShouldHideBannerWithText
    }
    
    func update(closeButtonDelay: TimeInterval) {
        self.closeButtonDelay = closeButtonDelay
    }
}

// MARK: - Private Methods -
private extension DefaultAdCreationService {
    /// Настраивает UIView для баннера на основе модели рекламы.
    @MainActor
    func configureBannerView(with adModel: AdModel, content: String) -> UIView {
        let analytics = DefaultBannerAnalytics(
            actionUrls: adModel.actionUrls,
            networkService: networkService
        )
        let bannerView = BannerView(
            analytics: analytics,
            shouldHideBannerWithText: isShouldHideBannerWithText,
            closeButtonDelay: closeButtonDelay
        )
        
        let height = CGFloat(adModel.height ?? 0)
        let width = calculateBannerWidth(from: adModel.width)
        bannerView.configureSize(height: height, width: width)
        bannerView.setHtmlContent(content)
        bannerView.loadContent()
        
        logger.log(AdConstants.bannerAdCreated)
        return bannerView
    }
    
    func calculateBannerWidth(from width: Int?) -> CGFloat {
        guard let width, width != 0 else { return UIScreen.main.bounds.width }
        return CGFloat(width)
    }
    
    /// Определяет, нужно ли автоматически обновлять баннер.
    func shouldAutoRefreshBanner(_ adModel: AdModel) -> Bool {
        adModel.showMultipleAds ?? false
    }
    
    /// Планирует регулярное обновление баннера через заданный интервал.
    @MainActor
    func scheduleBannerRefresh(for bannerView: UIView,
                               interval: TimeInterval,
                               requestModel: AdRequestModel,
                               previousAdModel: AdModel) {
        // Сброс предыдущего таймера.
        invalidateBannerTimer()
        
        logger.log(String(format: AdConstants.schedulingBannerRefresh, interval))
        bannerTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak bannerView] _ in
            Task { [weak bannerView] in
                guard let bannerView = bannerView else { return }
                await self.refreshBannerContent(for: requestModel,
                                                bannerView: bannerView,
                                                previousAdModel: previousAdModel)
            }
        }
    }
    
    /// Обновляет контент баннера, если данные изменились.
    @MainActor
    func refreshBannerContent(for requestModel: AdRequestModel,
                              bannerView: UIView,
                              previousAdModel: AdModel) async {
        do {
            let newAdModel = try await fetchAdData(for: requestModel)
            
            // Обновляем контент только если он новый.
            if let newContent = newAdModel.content, previousAdModel.adId != newAdModel.adId {
                logger.log(AdConstants.updatingBannerContent)
                if let banner = bannerView as? BannerView {
                    banner.setHtmlContent(newContent)
                    banner.loadContent()
                }
            } else {
                logger.log(AdConstants.bannerContentUnchanged)
            }
        } catch {
            logger.log("❌\(error.localizedDescription)")
        }
    }
    
    /// Останавливает таймер обновления баннера.
    @MainActor
    func invalidateBannerTimer() {
        bannerTimer?.invalidate()
        bannerTimer = nil
        logger.log(AdConstants.bannerRefreshTimerInvalidated)
    }
    
    /// Парсит VAST-файл и настраивает видеоплеер.
    @MainActor
    func loadVASTVideo(from fileURL: URL,
                       in containerView: UIView,
                       parentViewController: UIViewController) async {
        logger.log(AdConstants.parsingVASTFile)
        
        do {
            let vastModel = try await parseVASTFile(at: fileURL)
            logger.log(String(format: AdConstants.vastParsed, "\(vastModel)"))
            
            // Очищаем контейнер и добавляем плеер.
            containerView.subviews.forEach { $0.removeFromSuperview() }
            let playerView = VastVideoPlayerView(
                networkService: networkService,
                frame: containerView.bounds,
                closeButtonDelay: closeButtonDelay
            )
            playerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(playerView)
            
            NSLayoutConstraint.activate([
                playerView.topAnchor.constraint(equalTo: containerView.topAnchor),
                playerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                playerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                playerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
            
            playerView.configure(with: vastModel,
                                 in: containerView,
                                 parentViewController: parentViewController)
            logger.log(AdConstants.vastVideoLoaded)
            
        } catch {
            logger.log(AdConstants.errorParsingVASTPrefix + error.localizedDescription)
        }
    }
    
    /// Асинхронно парсит VAST-файл.
    func parseVASTFile(at fileURL: URL) async throws -> VastModel {
        try await withCheckedThrowingContinuation { continuation in
            vastService.parseVastFile(fileURL: fileURL) { vastModel, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let vastModel = vastModel {
                    continuation.resume(returning: vastModel)
                } else {
                    let parseError = NSError(domain: "VASTError",
                                             code: -1,
                                             userInfo: [NSLocalizedDescriptionKey: "An unknown error occurred while parsing VAST."])
                    continuation.resume(throwing: parseError)
                }
            }
        }
    }
    
    /// Загружает данные рекламы с сервера.
    func fetchAdData(for requestModel: AdRequestModel) async throws -> AdModel {
        logger.log(AdConstants.fetchingAdData)
        let adModel = try await networkService.fetchAd(with: requestModel)
        logger.log(AdConstants.adDataFetched)
        return adModel
    }
    
    func getCloseButtonDelay() -> TimeInterval {
        self.closeButtonDelay
    }
}
