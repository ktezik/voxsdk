import AVKit

fileprivate typealias Constants = VastVideoPlayerConstants

final class VastVideoPlayerView: UIView {
    
    // MARK: - Private Properties
    private let networkService: NetworkSevice
    private lazy var tracker: VideoTracker = DefaultVideoTracker(networkService: networkService)
    private let closeButtonDelay: TimeInterval
    
    private var playerViewController: AVPlayerViewController?
    private var clickThroughURL: URL?
    private var isMuted = false
    private var isPlaying = true
    
    private let clickButton = UIButton(type: .custom)
    private let progressBar = UIProgressView(progressViewStyle: .default)
    private let muteButton = UIButton(type: .custom)
    private let playPauseButton = UIButton(type: .custom)
    private let closeButton = UIButton(type: .custom)
    
    // MARK: - Initializer
    init(
        networkService: NetworkSevice,
        frame: CGRect,
        closeButtonDelay: TimeInterval
    ) {
        self.networkService = networkService
        self.closeButtonDelay = closeButtonDelay
        super.init(frame: frame)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    deinit {
        removeObservers()
        stopPlayback()
    }
    
    // MARK: - Life Cycle
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        muteButton.backgroundColor = .clear
        closeButton.backgroundColor = .clear
        playPauseButton.backgroundColor = .clear
    }
}

// MARK: - Public Methods -
extension VastVideoPlayerView {
    func configure(
        with vastModel: VastModel,
        in containerView: UIView,
        parentViewController: UIViewController
    ) {
        guard
            let vastFirstAd = vastModel.ads.first,
            let firstCreative = vastFirstAd.creatives.first,
            let linear = firstCreative.linear,
            let mediaFileURL = linear.files.mediaFiles.first(where: { $0.type == "video/mp4" })?.url
        else {
            return
        }
        tracker.setup(with: vastModel, and: vastFirstAd.id)
        
        clickThroughURL = linear.videoClicks.first(where: { $0.type == .clickThrough })?.url
        
        setupPlayer(with: mediaFileURL, in: containerView, parentViewController: parentViewController)
        setupUI(in: containerView)
        
        startTracking()
        
        // Показать кнопку закрытия с задержкой (значение delay берётся из VOXSDKConfig)
        DispatchQueue.main.asyncAfter(deadline: .now() + closeButtonDelay) { [weak self] in
            self?.closeButton.isHidden = false
        }
    }
}

// MARK: - Actions -
@objc private extension VastVideoPlayerView {
    func handleTap() {
        guard let url = clickThroughURL else { return }
        UIApplication.shared.open(url)
    }
    
    func toggleMute() {
        guard let player = playerViewController?.player else { return }
        isMuted.toggle()
        player.isMuted = isMuted
        let icon = isMuted ? Constants.muteButtonMutedIcon : Constants.muteButtonIcon
        tracker.receive(track: isMuted ? .mute : .unmute)
        muteButton.setImage(UIImage(systemName: icon), for: .normal)
    }
    
    func togglePlayPause() {
        guard let player = playerViewController?.player else { return }
        isPlaying.toggle()
        
        if isPlaying {
            player.play()
            tracker.receive(track: .resume)
            playPauseButton.setImage(UIImage(systemName: Constants.playPauseButtonPauseIcon), for: .normal)
        } else {
            player.pause()
            tracker.receive(track: .pause)
            playPauseButton.setImage(UIImage(systemName: Constants.playPauseButtonPlayIcon), for: .normal)
        }
    }
    
    func stopPlayback() {
        playerViewController?.player?.pause()
        [clickButton, progressBar, muteButton, playPauseButton, closeButton].forEach { $0.removeFromSuperview() }
        playerViewController?.player = nil
        tracker.receive(track: .close)
        tracker.reset()
        
        playerViewController?.view.removeFromSuperview()
        playerViewController?.removeFromParent()
        
        if let containerView = superview {
            containerView.removeFromSuperview()
            containerView.superview?.layoutIfNeeded()
        }
    }
    
    func videoDidEnd() {
        muteButton.isHidden = true
        playPauseButton.isHidden = true
        tracker.receive(track: .complete)
    }
}

// MARK: - Private Methods -
private extension VastVideoPlayerView {
    // MARK: - Настройка плеера
    private func setupPlayer(with url: URL, in containerView: UIView, parentViewController: UIViewController) {
        let player = AVPlayer(url: url)
        let playerVC = AVPlayerViewController()
        
        playerVC.player = player
        playerVC.view.frame = containerView.bounds
        playerVC.showsPlaybackControls = true
        
        parentViewController.addChild(playerVC)
        containerView.addSubview(playerVC.view)
        playerVC.didMove(toParent: parentViewController)
        
        self.playerViewController = playerVC
        addObservers(for: playerVC)
        player.play()
        tracker.adStart()
    }
    
    // MARK: - Настройка UI
    func setupUI(in view: UIView) {
        setupClickButton(in: view)
        setupProgressBar(in: view)
        setupMuteButton(in: view)
        setupPlayPauseButton(in: view)
        setupCloseButton(in: view)
    }
    
    // MARK: - Отслеживание прогресса воспроизведения
    func startTracking() {
        guard let player = playerViewController?.player else { return }
        
        let interval = CMTime(seconds: Constants.trackingInterval, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self, let duration = player.currentItem?.duration else { return }
            
            let currentTime = CMTimeGetSeconds(time)
            let totalDuration = CMTimeGetSeconds(duration)
            
            if totalDuration > 0 {
                self.progressBar.progress = Float(currentTime / totalDuration)
            }
            tracker.updateProgress(currentTime)
        }
    }
    
    // MARK: - Настройка кнопки для клика
    func setupClickButton(in view: UIView) {
        clickButton.frame = view.bounds
        clickButton.backgroundColor = .clear
        clickButton.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        view.addSubview(clickButton)
    }
    
    // MARK: - Настройка прогресс-бара
    func setupProgressBar(in view: UIView) {
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.progress = 0.0
        progressBar.progressTintColor = Constants.progressBarTintColor
        view.addSubview(progressBar)
        
        NSLayoutConstraint.activate([
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: Constants.progressBarHeight)
        ])
    }
    
    // MARK: - Настройка кнопки отключения звука
    func setupMuteButton(in view: UIView) {
        configureButton(muteButton, icon: Constants.muteButtonIcon, action: #selector(toggleMute), in: view)
        
        NSLayoutConstraint.activate([
            muteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.buttonMargin),
            muteButton.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.buttonMargin)
        ])
    }
    
    // MARK: - Настройка кнопки паузы/воспроизведения
    func setupPlayPauseButton(in view: UIView) {
        configureButton(
            playPauseButton,
            icon: Constants.playPauseButtonPauseIcon,
            action: #selector(togglePlayPause),
            in: view
        )
        
        NSLayoutConstraint.activate([
            playPauseButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.buttonMargin),
            playPauseButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Constants.buttonSpacing)
        ])
    }
    
    // MARK: - Настройка кнопки закрытия
    func setupCloseButton(in view: UIView) {
        configureButton(closeButton, icon: Constants.closeButtonIcon, action: #selector(stopPlayback), in: view)
        closeButton.isHidden = true
        
        NSLayoutConstraint.activate([
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.buttonMargin),
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.buttonMargin)
        ])
    }
    
    // MARK: - Универсальная настройка кнопки
    func configureButton(_ button: UIButton, icon: String, action: Selector, in view: UIView) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: icon), for: .normal)
        button.tintColor = Constants.buttonTintColor
        button.backgroundColor = Constants.buttonBackgroundColor
        button.layer.cornerRadius = Constants.buttonCornerRadius
        button.addTarget(self, action: action, for: .touchUpInside)
        view.addSubview(button)
    }
}

// MARK: - Observes -
private extension VastVideoPlayerView {
    func addObservers(for playerController: AVPlayerViewController) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(videoDidEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerController.player?.currentItem
        )
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}
