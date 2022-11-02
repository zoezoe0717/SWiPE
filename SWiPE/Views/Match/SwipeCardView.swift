//
//  SwipeCardView.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/1.
//

import UIKit

protocol SwipeCardsDelegate: AnyObject {
    func swipeDidEnd(on view: SwipeCardView)
    func swipeMatched(toMatch: Bool)
}

class SwipeCardView: UIView {
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
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    lazy private var label: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()

    weak var delegate: SwipeCardsDelegate?

    var divisor: CGFloat = 0
    let baseView = UIView()
    
    var dataSource: User? {
        didSet {
            imageView.loadImage(dataSource?.story)
            label.text = dataSource?.name
        }
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setConstraint()
        addPanGestureOnCards()
        configureTapGesture()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConstraint() {
        [shadowView, swipeView, label, imageView].forEach { subView in
            subView.translatesAutoresizingMaskIntoConstraints = false
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
        swipeView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: swipeView.leftAnchor),
            label.rightAnchor.constraint(equalTo: swipeView.rightAnchor),
            label.bottomAnchor.constraint(equalTo: swipeView.bottomAnchor),
            label.heightAnchor.constraint(equalToConstant: 85)
        ])
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

        let distanceFromCenter = ((UIScreen.main.bounds.width / 2) - card.center.x)
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
            } else if card.center.x < -65 {
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
            UIView.animate(withDuration: 0.2) {
                card.transform = .identity
                card.center = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
                self.layoutIfNeeded()
            }
        case .changed:
            let rotation = tan(point.x / (self.frame.width * 2.0))
            card.transform = CGAffineTransform(rotationAngle: rotation)

        default:
            break
        }
    }

    @objc func handleTapGesture(sender: UITapGestureRecognizer) {
    }
}
