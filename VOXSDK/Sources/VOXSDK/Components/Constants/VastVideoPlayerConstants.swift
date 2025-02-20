import UIKit

enum VastVideoPlayerConstants {
    // MARK: - Иконки кнопок
    static let muteButtonIcon: String = "speaker.wave.3.fill"
    static let muteButtonMutedIcon: String = "speaker.slash.fill"
    static let playPauseButtonPlayIcon: String = "play.fill"
    static let playPauseButtonPauseIcon: String = "pause.fill"
    static let closeButtonIcon: String = "xmark.circle.fill"
    
    // MARK: - Параметры кнопок
    static let buttonCornerRadius: CGFloat = 15.0
    static let buttonMargin: CGFloat = 10.0
    static let buttonSpacing: CGFloat = 10.0
    static let buttonBackgroundAlpha: CGFloat = 0.5
    static let buttonTintColor: UIColor = .white
    static let buttonBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.5)
    
    // MARK: - Прогресс-бар
    static let progressBarHeight: CGFloat = 3.0
    static let progressBarTintColor: UIColor = .red
    
    // MARK: - Интервал для отслеживания времени воспроизведения
    static let trackingInterval: Double = 0.5
}
