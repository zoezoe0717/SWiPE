//
//  StackContainerController.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/1.
//

import UIKit

protocol StackContainerViewDataSource {
    func numberOfCardsToShow() -> Int
    func card(at index: Int) -> SwipeCardView
    func emptyView() -> UIView?
}

protocol StackContainerViewDelegate: AnyObject {
    func swipeMatched(toMatch: Bool, index: Int)
}

class StackContainerView: UIView {
    var numberOfCardsToShow: Int = 0
    var remainingcards: Int = 0

    var cardsToBeVisible: Int = 3
    var cardViews: [SwipeCardView] = [] {
        didSet {
            cardViews.first?.queuePlayer.play()
        }
    }
    lazy var index = 0
    
    let horizontalInset: CGFloat = 10.0
    let verticalInset: CGFloat = 10.0
    
    var visibleCards: [SwipeCardView] {
        return subviews as? [SwipeCardView] ?? []
    }
    
    var dataSource: StackContainerViewDataSource? {
        didSet {
            reloadData()
        }
    }
    
    weak var delegate: StackContainerViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func reloadData() {
        removeAllCardViews()
        guard let datasource = dataSource else { return }
        setNeedsLayout()
        layoutIfNeeded()
        numberOfCardsToShow = datasource.numberOfCardsToShow()
        remainingcards = numberOfCardsToShow
        
        for i in 0..<min(numberOfCardsToShow, cardsToBeVisible) {
            addCardView(cardView: datasource.card(at: i), atIndex: i )
        }
    }

    private func addCardView(cardView: SwipeCardView, atIndex index: Int) {
        cardView.delegate = self
        addCardFrame(index: index, cardView: cardView)
        cardViews.append(cardView)
        insertSubview(cardView, at: 0)
        remainingcards -= 1
    }
    
    func addCardFrame(index: Int, cardView: SwipeCardView) {
        var cardViewFrame = bounds
        let horizontalInset = (CGFloat(index) * self.horizontalInset)
        let verticalInset = CGFloat(index) * self.verticalInset
        
        cardViewFrame.size.width -= 2 * horizontalInset
        cardViewFrame.origin.x += horizontalInset
        cardViewFrame.origin.y += verticalInset
        
        cardView.frame = cardViewFrame
    }
    
    private func removeAllCardViews() {
        for cardView in visibleCards {
            cardView.removeFromSuperview()
        }
        cardViews = []
    }
}

extension StackContainerView: SwipeCardsDelegate {
    func playerControl(removeCard: Bool) {
        let i = numberOfCardsToShow - remainingcards - 2

        if removeCard {
            cardViews[i].queuePlayer.pause()
            cardViews[i].queuePlayer.seek(to: .zero)
            return
        }
        
        cardViews[i].queuePlayer.play()
    }
    
    func swipeMatched(toMatch: Bool) {
        delegate?.swipeMatched(toMatch: toMatch, index: index)
        index += 1
    }
    
    func swipeDidEnd(on view: SwipeCardView) {
        guard let datasource = dataSource else { return }
        view.removeFromSuperview()
        view.queuePlayer.removeAllItems()
        view.playerLayer.removeFromSuperlayer()

        if remainingcards > 0 {
            let newIndex = datasource.numberOfCardsToShow() - remainingcards
            addCardView(cardView: datasource.card(at: newIndex), atIndex: 2)
            for (cardIndex, cardView) in visibleCards.reversed().enumerated() {
                UIView.animate(withDuration: 0.2, animations: {
                cardView.center = self.center
                    self.addCardFrame(index: cardIndex, cardView: cardView)
                    self.layoutIfNeeded()
                })
            }
        } else {
            for (cardIndex, cardView) in visibleCards.reversed().enumerated() {
                UIView.animate(withDuration: 0.2, animations: {
                    cardView.center = self.center
                    self.addCardFrame(index: cardIndex, cardView: cardView)
                    self.layoutIfNeeded()
                })
            }
        }
    }
}
