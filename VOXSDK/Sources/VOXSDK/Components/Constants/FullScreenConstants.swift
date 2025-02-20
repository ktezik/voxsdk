import UIKit

enum FullScreenBannerConstants {
    // MARK: - Константы кнопки закрытия
    static let closeButtonSize: CGFloat = 28.0
    static let closeButtonMargin: CGFloat = 14.0
    static let closeButtonTitle: String = "✕"
    static let closeButtonFontSize: CGFloat = 16.0
    static let closeButtonFontWeight: UIFont.Weight = .bold
    static let closeButtonBackgroundAlpha: CGFloat = 0.6
    static let closeButtonCornerRadius: CGFloat = 14.0
    static let closeButtonAnimationDuration: TimeInterval = 0.3
    
    // MARK: - Константы WebView
    static let jsHandlerName: String = "clickHandler"
    
    static let metaViewport: String = """
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    """
    
    static let jsClickHandler: String = """
    document.addEventListener('click', function(event) {
        window.webkit.messageHandlers.\(jsHandlerName).postMessage({
            tagName: event.target.tagName.toLowerCase(),
            href: event.target.href || '',
            text: event.target.innerText || ''
        });
    });
    """
}
