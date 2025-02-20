import UIKit

enum BannerViewConstants {
    // MARK: - Константы для кнопки закрытия
    static let closeButtonTopMargin: CGFloat = 14.0
    static let closeButtonSize: CGFloat = 14.0
    static let closeButtonTitle: String = "✕"
    static let closeButtonFontSize: CGFloat = 12.0
    static let closeButtonFontWeight: UIFont.Weight = .bold
    static let closeButtonBackgroundAlpha: CGFloat = 0.5
    
    // MARK: - Константы для отображения сообщения о скрытой рекламе
    static let adHiddenMessage: String = "Реклама скрыта"
    static let adHiddenFontSize: String = "18px"
    static var adHiddenHTML: String {
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body { margin: 0; display: flex; justify-content: center; align-items: center; height: 100vh; background-color: #f5f5f5; color: #333; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif; font-size: \(adHiddenFontSize); text-align: center; }
            </style>
        </head>
        <body>\(adHiddenMessage)</body>
        </html>
        """
    }
    
    // MARK: - Константы для JavaScript
    static let clickHandlerName: String = "clickHandler"
    static var clickDetectionScript: String {
        return """
        document.addEventListener('click', function(event) {
            window.webkit.messageHandlers.\(clickHandlerName).postMessage({
                tagName: event.target.tagName.toLowerCase(),
                href: event.target.href || '',
                text: event.target.innerText || ''
            });
        });
        """
    }
    
    static let metaName: String = "viewport"
    static let metaContent: String = "width=device-width, initial-scale=1.0, user-scalable=yes"
    
    static func viewportScript(for webViewWidth: CGFloat) -> String {
        return """
        var meta = document.createElement('meta');
        meta.name = '\(metaName)';
        meta.content = '\(metaContent)';
        document.getElementsByTagName('head')[0].appendChild(meta);
        
        var scale = \(webViewWidth) / document.body.scrollWidth;
        document.body.style.transform = 'scale(' + scale + ')';
        document.body.style.width = document.body.scrollWidth + 'px';

        // Получаем размеры элемента после применения скейла
        var rect = document.body.getBoundingClientRect();
        var newHeight = rect.height;

        // Возвращаем новые размеры
        newHeight;
        """
    }

    
    static var detectIframeNavigationScript: String {
        return """
        (function() {
            document.addEventListener('click', function(event) {
                var eventTarget = event.target;
                var checkedElements = [];
        
                function logAndSend(element, source) {
                    if (!element) return;
        
                    var elementInfo = {
                        tagName: element.tagName.toLowerCase(),
                        href: element.href || '',
                        hasOnClick: !!element.onclick,
                        source: source
                    };
        
                    console.log(" Проверено:", elementInfo);
                    window.webkit.messageHandlers.\(clickHandlerName).postMessage(elementInfo);
                }
        
                //  Проверяем сам элемент, по которому кликнули
                logAndSend(eventTarget, "clicked_element");
        
                //  Поднимаемся вверх по DOM, пока не найдем `A`, `BUTTON`, `DIV`
                while (eventTarget && eventTarget !== document) {
                    if (eventTarget.tagName.match(/^(A|BUTTON|DIV)$/i)) {
                        logAndSend(eventTarget, "parent_element");
                    }
                    eventTarget = eventTarget.parentElement;
                }
        
                //  Проверяем, изменился ли `window.location.href`
                setTimeout(function() {
                    var newUrl = window.location.href;
                    if (newUrl && newUrl !== "about:blank") {
                        logAndSend({ tagName: "document", href: newUrl }, "window_location");
                    }
                }, 500);
        
                //  Проверяем, есть ли `iframe`
                var iframe = document.querySelector("iframe");
                if (iframe) {
                    setTimeout(function() {
                        try {
                            var iframeUrl = iframe.contentWindow?.location.href;
                            if (iframeUrl && iframeUrl !== "about:blank") {
                                logAndSend({ tagName: "iframe", href: iframeUrl }, "iframe_navigation");
                            }
                        } catch (e) {
                            console.warn(" Доступ к iframe запрещен:", e);
                        }
                    }, 500);
                }
            }, true);
        })();
        """
    }
    
    // MARK: - Другие строковые константы
    static let jsErrorMessagePrefix: String = "Ошибка JavaScript: "
    static let clickLogPrefix: String = "👆 Клик по "
}
