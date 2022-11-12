//
//  SwipeCardView.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/1.
//

import UIKit
import AVFoundation

protocol SwipeCardsDelegate: AnyObject {
    func swipeDidEnd(on view: SwipeCardView)
    func swipeMatched(toMatch: Bool)
    func playerControl(removeCard: Bool)
}

class SwipeCardView: UIView {
//    lazy var player = AVPlayer()
//
    lazy var playerLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer(player: queuePlayer)
        layer.videoGravity = .resizeAspectFill
        return layer
    }()
    
    private var playerLooper: AVPlayerLooper!
    var queuePlayer: AVQueuePlayer!
    
    lazy private var swipeView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        return view
    }()
    
    lazy private var shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowOpacity = 0.8
        view.layer.shadowRadius = 4.0
        return view
    }()
    
    lazy private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFill
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
        [shadowView, swipeView, imageView].forEach { subView in
            subView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [nameLabel, ageLabel, introductionLabel].forEach { label in
            label.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // MARK: ShadowView
        addSubview(shadowView)
        NSLayoutConstraint.activate([
            shadowView.leftAnchor.constraint(equalTo: leftAnchor),
            shadowView.rightAnchor.constraint(equalTo: rightAnchor),
            shadowView.topAnchor.constraint(equalTo: topAnchor),
            shadowView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // MARK: SwipeView
        shadowView.addSubview(swipeView)
        NSLayoutConstraint.activate([
            swipeView.leftAnchor.constraint(equalTo: shadowView.leftAnchor),
            swipeView.rightAnchor.constraint(equalTo: shadowView.rightAnchor),
            swipeView.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor),
            swipeView.topAnchor.constraint(equalTo: shadowView.topAnchor)
        ])
        
        // MARK: ImageView
        swipeView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: swipeView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: swipeView.bottomAnchor),
            imageView.leftAnchor.constraint(equalTo: swipeView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: swipeView.rightAnchor)
        ])
        
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
    }
    
    private func playUrl(url: String?) {
        guard let urlString = url,
              let url = URL(string: urlString) else { return }
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        
        queuePlayer = AVQueuePlayer(playerItem: item)
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

        let _ = ((UIScreen.main.bounds.width / 2) - card.center.x)
        divisor = ((UIScreen.main.bounds.width / 2) / 0.61)
        
        switch sender.state {
        case .ended:
            if (card.center.x) > 400 {
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
            } else if card.center.x < -35 {
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
            let rotation = tan(point.x / (self.frame.width * 2.0))
            card.transform = CGAffineTransform(rotationAngle: rotation)
            
            if (card.center.x) > 300 {
                delegate?.playerControl(removeCard: false)
            } else if (card.center.x) < 70 {
                delegate?.playerControl(removeCard: false)
            }
        default:
            break
        }
    }

    @objc func handleTapGesture(sender: UITapGestureRecognizer) {
    }
}
