//
//  MatchVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/10/31.
//

import UIKit

class MatchVC: UIViewController {
    var viewModelData = [
        CardsDataModel(bgColor: UIColor(red:0.96, green:0.81, blue:0.46, alpha:1.0), text: "Hamburger", image: "hamburger"),
        CardsDataModel(bgColor: UIColor(red:0.29, green:0.64, blue:0.96, alpha:1.0), text: "Puppy", image: "puppy"),
        CardsDataModel(bgColor: UIColor(red:0.29, green:0.63, blue:0.49, alpha:1.0), text: "Poop", image: "poop"),
        CardsDataModel(bgColor: UIColor(red:0.69, green:0.52, blue:0.38, alpha:1.0), text: "Panda", image: "panda"),
        CardsDataModel(bgColor: UIColor(red:0.83, green:0.82, blue:0.69, alpha:1.0), text: "Robot", image: "robot")]
    var stackContainer: StackContainerView?
  
    override func loadView() {
        view = UIView()
        view.backgroundColor = .black
        stackContainer = StackContainerView()
        guard let stackContainer = stackContainer else { return }
        view.addSubview(stackContainer)
        configureStackContainer()
        stackContainer.translatesAutoresizingMaskIntoConstraints = false
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        stackContainer?.dataSource = self
    }
     
    func configureStackContainer() {
        guard let stackContainer = stackContainer else { return }
        stackContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        stackContainer.widthAnchor.constraint(equalToConstant: 350).isActive = true
        stackContainer.heightAnchor.constraint(equalToConstant: 600).isActive = true
    }
}

extension MatchVC: SwipeCardsDataSource {
    func numberOfCardsToShow() -> Int {
        return viewModelData.count
    }
    
    func card(at index: Int) -> SwipeCardView {
        let card = SwipeCardView()
        card.dataSource = viewModelData[index]
        return card
    }
    
    func emptyView() -> UIView? {
        return nil
    }
}
