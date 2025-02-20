import Foundation

enum NetworkConstants {
    static let baseURL = "https://ssp.hybrid.ai/auction/"
    static let userAgent = "iOS SDK"
    
    static let timeoutInterval: TimeInterval = 5
    
    // Сообщения об ошибках
    static let encodeRequestError = "🛜 Ошибка: не удалось закодировать модель запроса в JSON."
    static let buildURLError = "🛜 Ошибка: не удалось создать URL с query-параметром."
    static let invalidHTTPResponse = "🛜 Некорректный HTTP-ответ."
    static let jsonToStringError = "🛜 Не удалось преобразовать JSON в строку."
    static let jsonEncodeErrorPrefix = "🛜 Ошибка кодирования JSON: "
    static let jsonDecodeErrorPrefix = "🛜 Ошибка декодирования JSON: "
    static let jsonResponseErrorPrefix = "🛜 JSON-ответ, вызвавший ошибку: "
}
