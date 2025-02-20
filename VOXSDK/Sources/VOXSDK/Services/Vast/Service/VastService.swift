import Foundation

protocol VastService {
    func saveXMLToFile(xmlString: String, fileName: String) throws -> URL
    func parseVastFile(fileURL: URL, completion: @escaping (VastModel?, Error?) -> Void)
}
