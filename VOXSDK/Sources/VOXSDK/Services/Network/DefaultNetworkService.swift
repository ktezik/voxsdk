import Foundation

final class DefaultNetworkService {
    
    // MARK: - Private Properties
    private let logger = Logger.shared
    private let session: URLSession = .shared
    
}

// MARK: - NetworkSevice -
extension DefaultNetworkService: NetworkSevice {
    func fetchAd(with adRequestModel: AdRequestModel) async throws -> AdModel {
        guard let queryParameter = encodeToPercentEncodedJSON(adRequestModel: adRequestModel) else {
            logger.log(NetworkConstants.encodeRequestError)
            throw NetworkError.invalidURL
        }
        
        guard let url = buildURL(for: .getAd, with: queryParameter) else {
            logger.log(NetworkConstants.buildURLError)
            throw NetworkError.invalidURL
        }
        
        return try await performRequest(to: url)
    }
    
    func sendAnalytics(by urls: [URL], for event: String) {
        // Реализация с таймаутом и обработкой ошибки, необходимо утвередить реализацию и подрефакторить
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = NetworkConstants.timeoutInterval
        
        let session = URLSession(configuration: sessionConfiguration)
        
        urls.forEach { url in
            let task = session.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("❌ [\(event)] Ошибка: \(error.localizedDescription)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                        case 200..<300:
                            print("✅ [\(event)] Успешный запрос: \(url)")
                        default:
                            print("⚠️ [\(event)] Неудачный статус: \(httpResponse.statusCode)")
                    }
                }
            }
            task.resume()
        }
    }
}

// MARK: - Private Methods -
private extension DefaultNetworkService {
    /// Построение URL
    func buildURL(for endpoint: Endpoint, with queryParameter: String) -> URL? {
        let urlString = "\(NetworkConstants.baseURL)\(endpoint.rawValue)?request=\(queryParameter)"
        return URL(string: urlString)
    }
    
    /// Кодирование JSON в процентно-encoded строку
    func encodeToPercentEncodedJSON(adRequestModel: AdRequestModel) -> String? {
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(adRequestModel)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                logger.log(NetworkConstants.jsonToStringError)
                return nil
            }
            return jsonString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        } catch {
            logger.log(NetworkConstants.jsonEncodeErrorPrefix + error.localizedDescription)
            return nil
        }
    }
    
    /// Выполнение запроса с использованием async/await
    func performRequest(to url: URL) async throws -> AdModel {
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethod.get.rawValue
        request.addValue(NetworkConstants.userAgent, forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            logger.log(NetworkConstants.invalidHTTPResponse)
            throw NetworkError.invalidResponse
        }
        
        return try decodeAdModel(from: data)
    }
    
    /// Декодирование модели
    func decodeAdModel(from data: Data) throws -> AdModel {
        do {
            return try JSONDecoder().decode(AdModel.self, from: data)
        } catch {
            logger.log(NetworkConstants.jsonDecodeErrorPrefix + error.localizedDescription)
            if let jsonString = String(data: data, encoding: .utf8) {
                logger.log(NetworkConstants.jsonResponseErrorPrefix + jsonString)
            }
            throw error
        }
    }
}
