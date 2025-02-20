final class Logger {
    static let shared = Logger()
}

extension Logger {
    func log(_ message: String) {
        #if DEBUG
        print("\(message)")
        #endif
    }
}
