import Foundation

final class DefaultVastService {
    
    // MARK: - Private Properties
    private let vastClient = VastClient()
    
}

// MARK: - VastService -
extension DefaultVastService: VastService {
    /// Сохраняет строку XML в файл и возвращает URL этого файла
    /// - Parameters:
    ///   - xmlString: XML контент в виде строки
    ///   - fileName: Имя файла (без расширения)
    /// - Returns: URL сохраненного файла
    func saveXMLToFile(xmlString: String, fileName: String) throws -> URL {
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(fileName).appendingPathExtension("xml")
        
        do {
            try xmlString.write(to: fileURL, atomically: true, encoding: .utf16)
            return fileURL
        } catch {
            throw error
        }
    }
    
    /// Парсит VAST из файла
    /// - Parameters:
    ///   - fileURL: URL XML файла
    ///   - completion: Завершение с моделью VAST или ошибкой
    func parseVastFile(fileURL: URL, completion: @escaping (VastModel?, Error?) -> Void) {
        vastClient.parseVast(withContentsOf: fileURL, completion: completion)
    }
}
