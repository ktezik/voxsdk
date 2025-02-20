import UIKit
@preconcurrency import WebKit

fileprivate typealias Constants = FullScreenBannerConstants
fileprivate typealias BannerConstants = BannerViewConstants

/// Контроллер, отображающий полноэкранный баннер с HTML‑контентом.
final class FullScreenBannerViewController: UIViewController {
    
    // MARK: - Private Properties
    private let analytics: BannerAlaytics
    /// HTML‑контент, который будет отображаться в webView.
    private let htmlContent: String
    private let closeButtonDelay: TimeInterval
    private let logger = Logger.shared
    
    private var visibilityTimer: Timer?
    private var hasSentAnalytics = false
    
    /// WKWebView, занимающий весь экран.
    private lazy var webView: WKWebView = {
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
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.isScrollEnabled = false
        webView.allowsLinkPreview = false
        webView.navigationDelegate = self
        return webView
    }()
    
    /// Кнопка закрытия.
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.closeButtonTitle, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: Constants.closeButtonFontSize, weight: Constants.closeButtonFontWeight)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.black.withAlphaComponent(Constants.closeButtonBackgroundAlpha)
        button.layer.cornerRadius = Constants.closeButtonCornerRadius
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initializer
    init(
        analytics: BannerAlaytics,
        htmlContent: String,
        closeButtonDelay: TimeInterval
    ) {
        self.analytics = analytics
        self.htmlContent = htmlContent
        self.closeButtonDelay = closeButtonDelay
        super.init(nibName: nil, bundle: nil)
        analytics.loaded()
        modalPresentationStyle = .fullScreen
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupViews()
        loadContent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startVisibilityTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopVisibilityTracking()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !hasSentAnalytics {
            checkControllerVisibility()
        }
    }
}

// MARK: - WKNavigationDelegate (Обработка ссылок) -
extension FullScreenBannerViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        analytics.shown()
        jsScaleZoom()
        showCloseButtonWithDelay()
    }
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let url = navigationAction.request.url, navigationAction.navigationType == .linkActivated {
            if UIApplication.shared.canOpenURL(url) {
                analytics.click()
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }
        }
        decisionHandler(.allow)
    }
}

// MARK: - WKScriptMessageHandler (Обработка кликов в JS) -
extension FullScreenBannerViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
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
    
    func extractURLStartingFromCU(from urlString: String) -> String? {
        guard urlString.contains("cu=") else { return urlString }
        if let range = urlString.range(of: "cu=") {
            let extractedURL = String(urlString[range.upperBound...])
            return extractedURL
        }
        return nil
    }
}

// MARK: - Actions -
@objc private extension FullScreenBannerViewController {
    func closeButtonTapped() {
        analytics.close()
        dismiss(animated: true)
    }
}

// MARK: - Private Methods -
private extension FullScreenBannerViewController {
    func addClickDetectionScript(to contentController: WKUserContentController) {
        contentController.addUserScript(
            WKUserScript(source: BannerConstants.clickDetectionScript,
                         injectionTime: .atDocumentEnd,
                         forMainFrameOnly: false)
        )
    }
    
    func addScriptMessageHandler(to contentController: WKUserContentController) {
        contentController.add(self, name: BannerConstants.clickHandlerName)
    }
    
    func forceClickDetection(to contentController: WKUserContentController) {
        contentController.addUserScript(WKUserScript(
            source: BannerConstants.detectIframeNavigationScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        ))
    }
    
    func jsScaleZoom() {
        let script = BannerConstants.viewportScript(for: UIScreen.main.bounds.width)
        webView.evaluateJavaScript(script) { [weak self] _, error in
            if let error = error {
                self?.logger.log(BannerConstants.jsErrorMessagePrefix + error.localizedDescription)
            }
        }
    }
    
    func setupViews() {
        view.addSubview(webView)
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.closeButtonMargin),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.closeButtonMargin),
            closeButton.widthAnchor.constraint(equalToConstant: Constants.closeButtonSize),
            closeButton.heightAnchor.constraint(equalToConstant: Constants.closeButtonSize)
        ])
    }
    
    func showCloseButtonWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + closeButtonDelay) { [weak self] in
            UIView.animate(withDuration: Constants.closeButtonAnimationDuration) {
                self?.closeButton.isHidden = false
            }
        }
    }
    
    func loadContent() {
        let fullHtml = """
        <html>
        <head>
            \(Constants.metaViewport)
            <script>\(Constants.jsClickHandler)</script>
        </head>
        <body style='margin:0;padding:0;'>\(htmlContent)</body>
        </html>
        """
        
        webView.loadHTMLString(fullHtml, baseURL: nil)
    }
}

// MARK: - Analytics -
private extension FullScreenBannerViewController {
    func startVisibilityTracking() {
        guard !hasSentAnalytics else { return }
        
        stopVisibilityTracking()
        visibilityTimer = Timer.scheduledTimer(
            withTimeInterval: 0.25,
            repeats: true
        ) { [weak self] _ in
            self?.checkControllerVisibility()
        }
    }
    
    func checkControllerVisibility() {
        guard
            isViewLoaded,
            !hasSentAnalytics,
            let view = view,
            view.window != nil
        else { return }
        
        let visibility = calculateVisibility(for: view)
        if visibility >= 0.5 {
            sendAnalyticsEvent()
            hasSentAnalytics = true
            stopVisibilityTracking()
        }
    }
    
    func calculateVisibility(for targetView: UIView) -> CGFloat {
        guard
            !targetView.isHidden,
            targetView.alpha > 0,
            let window = targetView.window
        else { return 0 }
        
        let viewFrame = targetView.convert(targetView.bounds, to: window)
        let visibleFrame = viewFrame.intersection(window.bounds)
        
        let visibleArea = visibleFrame.width * visibleFrame.height
        let totalArea = viewFrame.width * viewFrame.height
        
        return totalArea > 0 ? (visibleArea / totalArea) : 0
    }
    
    func sendAnalyticsEvent() {
        analytics.visible()
    }
    
    func stopVisibilityTracking() {
        visibilityTimer?.invalidate()
        visibilityTimer = nil
    }
}
