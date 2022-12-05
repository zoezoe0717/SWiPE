//
//  SwipeCardView.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/1.
//

import UIKit
import AVFoundation
import Lottie

protocol SwipeCardsDelegate: AnyObject {
    func swipeDidEnd(on view: SwipeCardView)
    func swipeMatched(toMatch: Bool)
    func playerControl(removeCard: Bool)
}

class SwipeCardView: UIView {
    lazy var playerLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer(player: queuePlayer)
        layer.videoGravity = .resizeAspectFill
        
        return layer
    }()
    
    private var playerLooper: AVPlayerLooper?

    var queuePlayer: AVQueuePlayer?
    
    lazy private var swipeView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        
        return view
    }()
    
//    lazy private var shadowView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .clear
//        view.layer.shadowColor = UIColor.black.cgColor
//        view.layer.shadowOffset = CGSize(width: 0, height: 0)
//        view.layer.shadowOpacity = 0.8
//        view.layer.shadowRadius = 4.0
//
//        return view
//    }()
    
    lazy private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    lazy private var loadingView: LottieAnimationView = {
        let view = LottieAnimationView(name: LottieString.cardLoding.rawValue)
        view.loopMode = .loop
        view.animationSpeed = 0.8
        view.play()
        
        return view
    }()
    
    lazy private var likeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "success")
        imageView.alpha = 0
        
        return imageView
    }()
    
    lazy private var missImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "close")
        imageView.alpha = 0
        
        return imageView
    }()

    lazy private var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 40)
        
        return label
    }()
    
    lazy private var ageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 25)
        
        return label
    }()
    
    lazy private var introductionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        
        return label
    }()
    
    
    lazy private var moreOptionButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "more"), for: .normal)
        button.addTarget(self, action: #selector(moreOption), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: SwipeCardsDelegate?

    var divisor: CGFloat = 0
    let baseView = UIView()
    
    var dataSource: User? {
        didSet {
            guard let dataSource = dataSource else { return }
            nameLabel.text = dataSource.name
            ageLabel.text = "\(dataSource.age)"
            introductionLabel.text = dataSource.introduction
            playUrl(url: dataSource.video)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setConstraint()
        addPanGestureOnCards()
        configureTapGesture()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.addSublayer(playerLayer)
        playerLayer.frame = self.bounds
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConstraint() {
        [swipeView, imageView, loadingView, likeImageView, missImageView].forEach { subView in
            subView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [nameLabel, ageLabel, introductionLabel, moreOptionButton].forEach { label in
            label.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // MARK: ShadowView
//        addSubview(shadowView)
//        NSLayoutConstraint.activate([
//            shadowView.leftAnchor.constraint(equalTo: leftAnchor),
//            shadowView.rightAnchor.constraint(equalTo: rightAnchor),
//            shadowView.topAnchor.constraint(equalTo: topAnchor),
//            shadowView.bottomAnchor.constraint(equalTo: bottomAnchor)
//        ])
        
        // MARK: SwipeView
        addSubview(swipeView)
        NSLayoutConstraint.activate([
            swipeView.leftAnchor.constraint(equalTo: leftAnchor),
            swipeView.rightAnchor.constraint(equalTo: rightAnchor),
            swipeView.bottomAnchor.constraint(equalTo: bottomAnchor),
            swipeView.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        // MARK: ImageView
        swipeView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: swipeView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: swipeView.bottomAnchor),
            imageView.leftAnchor.constraint(equalTo: swipeView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: swipeView.rightAnchor)
        ])
        
        // MARK: LodingView
        imageView.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: swipeView.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: swipeView.centerYAnchor),
            loadingView.heightAnchor.constraint(equalTo: swipeView.heightAnchor, multiplier: 0.5),
            loadingView.widthAnchor.constraint(equalTo: swipeView.heightAnchor, multiplier: 0.5)
        ])
        
        // MARK: LikeImagView & MissImageView
        [likeImageView, missImageView].forEach { view in
            swipeView.addSubview(view)
            NSLayoutConstraint.activate([
                view.heightAnchor.constraint(equalTo: swipeView.widthAnchor, multiplier: 0.25),
                view.widthAnchor.constraint(equalTo: swipeView.widthAnchor, multiplier: 0.25),
                view.topAnchor.constraint(equalTo: swipeView.topAnchor, constant: 10)
            ])
        }
        
        likeImageView.leftAnchor.constraint(equalTo: swipeView.leftAnchor, constant: 10).isActive = true
        missImageView.rightAnchor.constraint(equalTo: swipeView.rightAnchor, constant: -10).isActive = true
        
        // MARK: NameLabel
        swipeView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.leftAnchor.constraint(equalTo: swipeView.leftAnchor, constant: 20),
            nameLabel.bottomAnchor.constraint(equalTo: swipeView.bottomAnchor, constant: -60)
        ])
        
        // MARK: AgeLabel
        swipeView.addSubview(ageLabel)
        NSLayoutConstraint.activate([
            ageLabel.leftAnchor.constraint(equalTo: nameLabel.rightAnchor, constant: 10),
            ageLabel.bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor)
        ])
        
        // MARK: IntroductionLabel
        swipeView.addSubview(introductionLabel)
        NSLayoutConstraint.activate([
            introductionLabel.leftAnchor.constraint(equalTo: swipeView.leftAnchor, constant: 20),
            introductionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5)
        ])
        
        swipeView.addSubview(moreOptionButton)
        NSLayoutConstraint.activate([
            moreOptionButton.widthAnchor.constraint(equalToConstant: 40),
            moreOptionButton.heightAnchor.constraint(equalToConstant: 40),
            moreOptionButton.centerYAnchor.constraint(equalTo: ageLabel.centerYAnchor, constant: 20),
            moreOptionButton.rightAnchor.constraint(equalTo: swipeView.rightAnchor, constant: -20)
        ])
    }
    
    private func fadeInAndOutAnimate(imageView: UIImageView, alpha: CGFloat) {
        UIView.animate(withDuration: 0.5) {
            imageView.alpha = alpha
        }
    }
    
    private func playUrl(url: String?) {
        guard let urlString = url,
            let url = URL(string: urlString) else { return }
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        
        queuePlayer = AVQueuePlayer(playerItem: item)
        
        guard let queuePlayer = queuePlayer else { return }
        
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: item)
    }

    func configureTapGesture() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGesture)))
    }


    func addPanGestureOnCards() {
        self.isUserInteractionEnabled = true
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture)))
    }

    @objc func handlePanGesture(sender: UIPanGestureRecognizer) {
        guard let card = sender.view as? SwipeCardView else { return }
        let point = sender.translation(in: self)
        let centerOfParentContainer = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        card.center = CGPoint(x: centerOfParentContainer.x + point.x, y: centerOfParentContainer.y + point.y)

        _ = ((UIScreen.main.bounds.width / 2) - card.center.x)
        divisor = ((UIScreen.main.bounds.width / 2) / 0.61)
        
        switch sender.state {
        case .ended:
            [likeImageView, missImageView].forEach({ fadeInAndOutAnimate(imageView: $0, alpha: 0) })

            if (card.center.x) > 320 {
                delegate?.swipeMatched(toMatch: true)
                delegate?.swipeDidEnd(on: card)
                UIView.animate(withDuration: 0.2) {
                    card.center = CGPoint(
                        x: centerOfParentContainer.x + point.x + 200,
                        y: centerOfParentContainer.y + point.y + 75
                    )
                    card.alpha = 0
                    self.layoutIfNeeded()
                }
                return
            } else if card.center.x < 90 {
                delegate?.swipeMatched(toMatch: false)
                delegate?.swipeDidEnd(on: card)
                UIView.animate(withDuration: 0.2) {
                    card.center = CGPoint(
                        x: centerOfParentContainer.x + point.x - 200,
                        y: centerOfParentContainer.y + point.y + 75
                    )
                    card.alpha = 0
                    self.layoutIfNeeded()
                }
                return
            }
            delegate?.playerControl(removeCard: true)
            UIView.animate(withDuration: 0.2) {
                card.transform = .identity
                card.center = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
                self.layoutIfNeeded()
            }
        case .changed:
            let rotation = tan(point.x / (self.frame.width * 2.5))
            card.transform = CGAffineTransform(rotationAngle: rotation)
            
            let wasDeleted = (card.center.x > 300) || (card.center.x < 100)
            let isCloseToMiss = card.center.x < 130
            let isCloseToLike = card.center.x > 220
            
            if wasDeleted {
                delegate?.playerControl(removeCard: false)
            } else if isCloseToLike {
                fadeInAndOutAnimate(imageView: likeImageView, alpha: 1)
            } else if isCloseToMiss {
                fadeInAndOutAnimate(imageView: missImageView, alpha: 1)
            } else {
                [likeImageView, missImageView].forEach({ fadeInAndOutAnimate(imageView: $0, alpha: 0) })
            }
        default:
            break
        }
    }
    
    @objc func moreOption() {
        guard let id = dataSource?.id else { return }
        ZAlertView.share.showProsecute(id: id)
    }
    
    @objc func handleTapGesture(sender: UITapGestureRecognizer) {
        queuePlayer?.play()
    }
}
