protocol VideoTracker {
    func setup(with model: VastModel, and adId: String)
    func reset()
    func updateProgress(_ seconds: Double)
    func adStart()
    func adComplete()
    func receive(track type: TrackerType)
}
