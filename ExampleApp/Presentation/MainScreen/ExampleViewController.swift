import UIKit
import VOXSDK

final class ExampleViewController: UIViewController {
    
    // MARK: - Private Prtoperties
    private lazy var presenter = ExamplePresenter(view: self)
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 20
        view.alignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Clear banners", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(clearAction), for: .touchUpInside)
        return button
    }()
    
    /// Используется для хранения названия кейса, с которым связан загружаемый баннер.
    private var currentBannerTitle: String?
    /// Контейнер для видео рекламы, создаётся при необходимости
    private var videoContainerView: UIView?
    
    // MARK: - Initializer
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.confiAD()
    }
    
    // MARK: - Actions
    @objc private func buttonTapped(_ sender: AdButton) {
        guard let place = sender.place else { return }
        if place == .fullScreenBanner {
            presenter.presentAd(for: place.rawValue, vc: self)
        } else if place == .horizontalVideo || place == .verticalVideo {
            setupVideoContainer(with: place)
        } else {
            // Сохраняем название кейса для дальнейшего использования в displayBanner
            currentBannerTitle = String(describing: place)
            presenter.getAd(for: place.rawValue)
        }
    }
    
    @objc private func clearAction() {
        stackView.subviews.forEach { view in
            guard !(view is AdButton) && !(view is UILabel) else { return }
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        videoContainerView = nil
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .white
        setupScrollView()
        setupStackView()
        setupButtons()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupStackView() {
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 50),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -50)
        ])
    }
    
    private func setupButtons() {
        setupClearButton()
        // Заголовок для кнопок кейсов
        let titleLabel = UILabel()
        titleLabel.text = "Banner кейсы"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textColor = .black
        stackView.addArrangedSubview(titleLabel)
        
        // Для каждого кейса из enum создаём свою кнопку
        for place in PlaceID.allCases {
            let button = createButtonForPlace(place)
            stackView.addArrangedSubview(button)
        }
    }
    
    private func setupClearButton() {
        view.addSubview(clearButton)
        NSLayoutConstraint.activate([
            clearButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            clearButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    /// Создаёт кнопку для заданного кейса PlaceID.
    private func createButtonForPlace(_ place: PlaceID) -> AdButton {
        let button = AdButton(type: .system)
        button.place = place
        button.layer.cornerRadius = 8
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.setTitle(String(describing: place), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.widthAnchor.constraint(equalToConstant: 250).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return button
    }
    
    private func setupVideoContainer(with place: PlaceID) {
        videoContainerView = UIView()
        guard var videoContainerView else { return }
        // Если контейнер для видео ещё не добавлен в stackView – добавляем его
        if videoContainerView.superview == nil {
            videoContainerView.translatesAutoresizingMaskIntoConstraints = false
            videoContainerView.backgroundColor = .black
            stackView.addArrangedSubview(videoContainerView)
            NSLayoutConstraint.activate([
                videoContainerView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
                videoContainerView.heightAnchor.constraint(
                    equalTo: videoContainerView.widthAnchor,
                    multiplier: 9.0 / 16.0
                )
            ])
        }
        presenter.getVideoAd(for: place.rawValue, in: videoContainerView, vc: self)
    }
}

// MARK: - ExampleView -
extension ExampleViewController: ExampleView {
    func displayBanner(_ banner: UIView) {
        DispatchQueue.main.async {
            // Создаем контейнер для заголовка и баннера
            let container = UIStackView()
            container.axis = .vertical
            container.alignment = .center
            container.spacing = 5
            container.translatesAutoresizingMaskIntoConstraints = false
            
            if let title = self.currentBannerTitle {
                let titleLabel = UILabel()
                titleLabel.text = title
                titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
                titleLabel.textColor = .darkGray
                container.addArrangedSubview(titleLabel)
            }
            
            banner.translatesAutoresizingMaskIntoConstraints = false
            container.addArrangedSubview(banner)
            
            // Если известны размеры баннера, можно добавить ограничения (иначе их можно задавать динамически)
            if banner.frame != .zero {
                NSLayoutConstraint.activate([
                    banner.widthAnchor.constraint(equalToConstant: banner.frame.width),
                    banner.heightAnchor.constraint(equalToConstant: banner.frame.height)
                ])
            }
            
            self.stackView.addArrangedSubview(container)
            self.stackView.setNeedsLayout()
            
            self.currentBannerTitle = nil
        }
    }
}
