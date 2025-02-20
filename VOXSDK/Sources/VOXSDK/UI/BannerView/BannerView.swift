import UIKit
@preconcurrency import WebKit

fileprivate typealias Constants = BannerViewConstants

/// UIView с WKWebView для отображения баннера
final class BannerView: UIView {
    
    // MARK: - Private Properties
    private let analytics: BannerAlaytics
    private let shouldHideBannerWithText: Bool
    private let closeButtonDelay: TimeInterval
    private var htmlContent = ""
    private var repeatingTimer: Timer?
    
    private lazy var webView: WKWebView = createWebView()
    private lazy var closeButton: UIButton = createCloseButton()
    private let logger = Logger.shared
    
    private lazy var closeButtonTopConstraint = closeButton.topAnchor.constraint(
        equalTo: topAnchor,
        constant: Constants.closeButtonTopMargin
    )
    private var visibilityCheckTimer: Timer?
    private var hasSentAnalytics = false
    
    // MARK: - Initializer
    init(
        analytics: BannerAlaytics,
        shouldHideBannerWithText: Bool,
        closeButtonDelay: TimeInterval
    ) {
        self.analytics = analytics
        self.shouldHideBannerWithText = shouldHideBannerWithText
        self.closeButtonDelay = closeButtonDelay
        super.init(frame: .zero)
        analytics.loaded()
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    deinit {
        stopVisibilityCheck()
    }
    
    // MARK: - Life Cycle
    override func didMoveToWindow() {
        super.didMoveToWindow()
        startVisibilityCheckIfNeeded()
    }
}

// MARK: - WKNavigationDelegate -
extension BannerView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        analytics.shown()
        jsScaleZoom()
        showCloseButton()
    }
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        if navigationAction.navigationType == .linkActivated, UIApplication.shared.canOpenURL(url) {
            analytics.click()
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}

// TODO: - вынести в константы, и лучше наверно разделить html5 логику и обычного банера
// MARK: - WKScriptMessageHandler -
extension BannerView: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        logger.log(" Получено сообщение из WKWebView: \(message.body)")
        
        guard let body = message.body as? [String: Any] else {
            logger.log(" Ошибка: message.body не является словарем")
            return
        }
        
        if let href = body["href"] as? String, !href.isEmpty {
            logger.log(" Найдена ссылка: \(href)")
            
            // Удаляем все до `cu=` и передаем чистую ссылку
            if let cleanURL = extractURLStartingFromCU(from: href) {
                logger.log(" Открываем финальный редирект: \(cleanURL)")
                if let url = URL(string: cleanURL) {
                    DispatchQueue.main.async {
                        self.analytics.click()
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            } else {
                logger.log(" Не удалось извлечь ссылку, ждем правильный редирект...")
            }
        }
    }
    
    // Функция для извлечения URL после `cu=`
    func extractURLStartingFromCU(from urlString: String) -> String? {
        if let range = urlString.range(of: "cu=") {
            let extractedURL = String(urlString[range.upperBound...])
            return extractedURL
        }
        return nil
    }
}

// MARK: - Public Methods -
// Загрузка и настройки контента
extension BannerView {
    func loadContent() {
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }
    
    func setHtmlContent(_ value: String) {
        htmlContent = value
    }
    
    func configureSize(height: CGFloat, width: CGFloat) {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: min(width, UIScreen.main.bounds.width)),
            heightAnchor.constraint(equalToConstant: height)
        ])
    }
    
    func startRepeatingTimer(_ sec: Double, onTick: @escaping () -> Void) {
        repeatingTimer = Timer.scheduledTimer(withTimeInterval: sec, repeats: true) { _ in onTick() }
    }
    
    func stopTimer() {
        repeatingTimer?.invalidate()
    }
}

// MARK: - Actions -
@objc private extension BannerView {
    func closeButtonTapped() {
        closeButton.isHidden = true
        analytics.close()
        if shouldHideBannerWithText {
            showAdHiddenMessage()
        } else {
            removeFromSuperview()
        }
        stopTimer()
    }
}

// MARK: - Private Methods -
private extension BannerView {
    func setupViews() {
        addSubview(webView)
        addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            // WebView занимает весь экран
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Кнопка закрытия
            closeButtonTopConstraint,
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: Constants.closeButtonSize),
            closeButton.heightAnchor.constraint(equalToConstant: Constants.closeButtonSize)
        ])
    }
    
    func createWebView() -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: createWebViewConfiguration())
        configureScrollView(webView.scrollView)
        webView.allowsLinkPreview = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        return webView
    }
    
    func configureScrollView(_ scrollView: UIScrollView) {
        scrollView.isScrollEnabled = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
    
    func createWebViewConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        
        addClickDetectionScript(to: contentController)
        addScriptMessageHandler(to: contentController)
        forceClickDetection(to: contentController)
        
        configuration.userContentController = contentController
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.allowsAirPlayForMediaPlayback = true
        
        return configuration
    }
    
    func createCloseButton() -> UIButton {
        let button = UIButton(type: .system)
        button.isHidden = true
        button.setTitle(Constants.closeButtonTitle, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: Constants.closeButtonFontSize, weight: Constants.closeButtonFontWeight)
        button.setTitleColor(UIColor.black.withAlphaComponent(0.35), for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.withAlphaComponent(0.35).cgColor
        button.backgroundColor = UIColor.white.withAlphaComponent(Constants.closeButtonBackgroundAlpha)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }
    
    func showCloseButton() {
        DispatchQueue.main.asyncAfter(deadline: .now() + closeButtonDelay) { [weak self] in
            self?.closeButton.isHidden = false
        }
    }
    
    func showAdHiddenMessage() {
        webView.loadHTMLString(Constants.adHiddenHTML, baseURL: nil)
    }
    
    // MARK: - JavaScript
    func addClickDetectionScript(to contentController: WKUserContentController) {
        contentController.addUserScript(
            WKUserScript(source: Constants.clickDetectionScript,
                         injectionTime: .atDocumentEnd,
                         forMainFrameOnly: false)
        )
    }
    
    func addScriptMessageHandler(to contentController: WKUserContentController) {
        contentController.add(self, name: Constants.clickHandlerName)
    }
    
    func forceClickDetection(to contentController: WKUserContentController) {
        contentController.addUserScript(
            WKUserScript(
                source: Constants.detectIframeNavigationScript,
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: false
            )
        )
    }
    
    func jsScaleZoom() {
        let script = Constants.viewportScript(for: webView.bounds.width)
        webView.evaluateJavaScript(script) { [weak self] (result, error) in
            guard let self else { return }
            if let height = result as? Double {
                let closeButtonInset = (self.webView.bounds.height - height) / 2
                self.updateCloseButton(inset: closeButtonInset, scale: self.webView.bounds.height / height)
            }
        }
    }
    
    func updateCloseButton(inset: CGFloat, scale: CGFloat) {
        closeButtonTopConstraint.constant = inset + (Constants.closeButtonTopMargin / scale)
        layoutIfNeeded()
    }
}

// MARK: - Analytics -
private extension BannerView {
    func startVisibilityCheckIfNeeded() {
        guard window != nil, !hasSentAnalytics else { return }
        
        stopVisibilityCheck()
        visibilityCheckTimer = Timer.scheduledTimer(
            withTimeInterval: 0.25,
            repeats: true
        ) { [weak self] _ in
            self?.checkVisibility()
        }
    }
    
    func checkVisibility() {
        guard !hasSentAnalytics else { return }
        
        if calculateVisibility() >= 0.5 {
            sendAnalyticsEvent()
            hasSentAnalytics = true
            stopVisibilityCheck()
        }
    }
    
    func calculateVisibility() -> CGFloat {
        guard
            !isHidden,
            alpha > 0,
            superview != nil,
            let window = window
        else { return 0 }
        
        // Конвертируем bounds баннера в координаты окна
        let viewFrameInWindow = convert(bounds, to: window)
        
        // Получаем область пересечения с экраном
        let visibleFrame = viewFrameInWindow.intersection(window.bounds)
        
        // Рассчитываем соотношение площадей
        let visibleArea = visibleFrame.width * visibleFrame.height
        let totalArea = viewFrameInWindow.width * viewFrameInWindow.height
        
        return totalArea > 0 ? visibleArea / totalArea : 0
    }
    
    func sendAnalyticsEvent() {
        analytics.visible()
    }
    
    func stopVisibilityCheck() {
        visibilityCheckTimer?.invalidate()
        visibilityCheckTimer = nil
    }
}
