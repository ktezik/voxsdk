import Foundation

final class DefaultVideoTracker {
    
    // MARK: - Types
    typealias LogOutput = (String, [URL]) -> ()
    
    // MARK: - Private Properties
    private let networkService: NetworkSevice
    private var tracker: VastTracker?
    private var adId: String?
    
    private let logger = Logger.shared
    private var logOutput: LogOutput?
    
    // MARK: - Initializer
    init(networkService: NetworkSevice) {
        self.networkService = networkService
    }
    
    deinit {
        reset()
    }
}

// MARK: - VideoTracker -
extension DefaultVideoTracker: VideoTracker {
    func setup(with model: VastModel, and adId: String) {
        self.adId = adId
        tracker = VastTracker(vastModel: model)
        setupLogOutput()
    }
    
    func reset() {
        tracker = nil
    }
    
    func updateProgress(_ seconds: Double) {
        do {
            try tracker?.updateProgress(time: seconds)
        } catch {
            logger.log(VideoTrackerConstants.updateProgressError)
        }
    }
    
    func adStart() {
        do {
            let adIdentifier = try getAdIdentifier()
            try tracker?.trackAdStart(withId: adIdentifier)
        } catch {
            logger.log(VideoTrackerConstants.trackAdStartError)
        }
    }
    
    func adComplete() {
        do {
            try tracker?.trackAdComplete()
        } catch {
            logger.log(VideoTrackerConstants.trackAdCompleteError)
        }
    }
    
    func receive(track type: TrackerType) {
        do {
            try processReceive(track: type)
        } catch {
            logger.log(VideoTrackerConstants.receiveTrackTypeError)
        }
    }
}

// MARK: - Private Methods -
private extension DefaultVideoTracker {
    func getAdIdentifier() throws -> String {
        guard let adId else {
            logger.log(VideoTrackerConstants.emptyAdId)
            throw NSError()
        }
        return adId
    }
    
    func setupLogOutput() {
        VastClient.trackingLogOutput = { [weak self] event, urls in
            guard !IgnoredTrackerType.contains(rawValue: event) else { return }
            self?.networkService.sendAnalytics(by: urls, for: event)
        }
    }
    
    func processReceive(track type: TrackerType) throws {
        switch type {
            case .pause:
                try tracker?.paused()
            case .resume:
                try tracker?.played()
            case .mute:
                try tracker?.muted(true)
            case .unmute:
                try tracker?.muted(false)
            case .complete:
                try tracker?.trackAdComplete()
            case .close:
                try tracker?.closed()
        }
    }
}
