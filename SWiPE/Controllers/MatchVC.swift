//
//  MatchVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/10/31.
//

import UIKit

class MatchVC: UIViewController {
    private var matchData: [User]? {
        
        didSet {
            stackContainer?.reloadData()
        }
    }
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        stackContainer?.dataSource = self
    }
    
    private func fetchData() {
        FireBaseManager.shared.fetchUser { [weak self] result in
            switch result {
            case .success(let users):
                self?.matchData = users
            case .failure(let error):
                print(error)
            }
        }
    }
     
    private func configureStackContainer() {
        guard let stackContainer = stackContainer else { return }
        stackContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        stackContainer.widthAnchor.constraint(equalToConstant: 350).isActive = true
        stackContainer.heightAnchor.constraint(equalToConstant: 600).isActive = true
    }
}

extension MatchVC: SwipeCardsDataSource {
    func numberOfCardsToShow() -> Int {
        return matchData?.count ?? 5
    }
    
    func card(at index: Int) -> SwipeCardView {
        let card = SwipeCardView()
        card.dataSource = matchData?[index]
        return card
    }
    
    func emptyView() -> UIView? {
        return nil
    }
}
