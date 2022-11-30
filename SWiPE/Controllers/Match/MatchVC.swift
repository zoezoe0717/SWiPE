//
//  MatchVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/10/31.
//

import UIKit
import CoreLocation
import Lottie
import FirebaseAuth

class MatchVC: UIViewController {
    var mockUserData = User(
        id: UserUid.share.getUid(),
        name: "Zoe",
        email: "123@gmail.com",
        latitude: 0,
        longitude: 0,
        age: 20,
        story: "https://i.imgur.com/4Vc3NZR.png",
        video: "https://i.imgur.com/1NLECXT.mp4",
        introduction: "嘻嘻嘻嘻嘻嘻",
        createdTime: 0,
        index: ""
    )
    
    lazy private var matchAnimationView: LottieAnimationView = {
        let view = LottieAnimationView(name: LottieString.match.rawValue)

        view.contentMode = .scaleAspectFill
        view.isHidden = true
        return view
    }()
    
    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "SWiPER"
        
        return label
    }()
    
    lazy private var titleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "SwipeTitle")
        
        return imageView
    }()
    
    private let locationManager = CLLocationManager()
    
    private var fullScreen: CGSize?

    private var matchData: [User]? {
        didSet {
            stackContainer?.reloadData()
        }
    }
    
    var stackContainer: StackContainerView? {
        didSet {
            stackContainer?.delegate = self
            stackContainer?.dataSource = self
        }
    }
    
    override func loadView() {
        super.loadView()
        setStackContainer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fullScreen = UIScreen.main.bounds.size
        configureStackContainer()
        setAnimation()
        
//        for i in 0..<20 {
//            print("===\(i)")
//            addMockData()
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !UserUid.share.getUid().isEmpty {
            print("===\(UserUid.share.getUid())")
            fetchData()
        }
        
        stackContainer?.cardViews.forEach { card in
            if card.frame.minX == 0 {
                card.queuePlayer?.play()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stackContainer?.cardViews.forEach { card in
            if card.frame.minX == 0 {
                card.queuePlayer?.pause()
            }
        }
    }
    
    private func addMockData() {
        for i in 0..<MockUser.mockUserDatas.count {
            add(with: &MockUser.mockUserDatas[i])
        }
    }
    
    private func setStackContainer() {
        view = UIView()
        view.backgroundColor = CustomColor.base.color
        stackContainer = StackContainerView()
        guard let stackContainer = stackContainer else { return }
        view.addSubview(stackContainer)
        stackContainer.translatesAutoresizingMaskIntoConstraints = false
    }
     
    private func configureStackContainer() {
        guard let stackContainer = stackContainer,
            let fullScreen = fullScreen else { return }

        stackContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        stackContainer.widthAnchor.constraint(equalToConstant: fullScreen.width * 0.95).isActive = true
        stackContainer.heightAnchor.constraint(equalToConstant: fullScreen.height * 0.75).isActive = true
    }
    
    private func setAnimation() {
        [matchAnimationView].forEach { sub in
            view.addSubview(sub)
            sub.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            matchAnimationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            matchAnimationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            matchAnimationView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            matchAnimationView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1)
        ])
    }
    
    private func playMatchAnimation(_ isMatch: Bool) {
        if isMatch {
            matchAnimationView.isHidden = false
            matchAnimationView.play { _ in self.matchAnimationView.isHidden = true }
        }
    }
    
    
    //    func convertLocation(lat latitude: CLLocationDegrees, lon longitude: CLLocationDegrees) {
//        let geocoder = CLGeocoder()
//        let loc = CLLocation(latitude: latitude, longitude: longitude)
//
//        let locale = Locale(identifier: "zh_TW")
//        geocoder.reverseGeocodeLocation(loc, preferredLocale: locale) {
//            placemarks, error in
//            if let error = error {
//                print(error)
//            } else {
//                guard let placemarks = placemarks else { return }
//
//                if !placemarks.isEmpty {
//                    guard let country = placemarks.first?.country,
//                          let locality = placemarks.first?.locality else {
//                        return
//                    }
//                }
//            }
//        }
//    }
}
// MARK: Firebase
extension MatchVC {
    private func fetchData() {
        FireBaseManager.shared.getUser { result in
            switch result {
            case .success(let user):

                guard let user = user else { return }
                SignVC.userData = user

                if !SignVC.userData.index.isEmpty {
                    FireBaseManager.shared.getMatchListener(dbName: SignVC.userData.index) { [weak self] result in
                        switch result {
                        case .success(let success):
                            self?.matchData = success
//                            print("===\(success[0])")
                        case .failure(let failure):
                            print(failure)
                        }
                    }
                }

            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    private func add(with user: inout User) {
        FireBaseManager.shared.addUser(user: &user) { result in
            switch result {
            case .success(let message):
                print(message)
            case .failure(let error):
                print("DEBUG: \(error)")
            }
        }
    }
    
    private func searchID(user: User, netizen: User) {
        FireBaseManager.shared.searchUser(user: user, netizen: netizen) { result in
            switch result {
            case .success(let isMatch):
                self.playMatchAnimation(isMatch)
            case .failure(let error):
                print("DEBUG: \(error)")
            }
        }
    }
    
    private func serachBeLike(user: User, netizen: User) {
        FireBaseManager.shared.searchBeLike(user: user, netizen: netizen) { result in
            switch result {
            case .success(let success):
                print(success)
            case .failure(let error):
                print("DEBUG: \(error)")
            }
        }
    }
    
    private func updateIndex(index: Int) {
        FireBaseManager.shared.updateUserData(user: SignVC.userData, data: ["index": matchData?[index].id])
    }
}

// MARK: Swipe Card
extension MatchVC: StackContainerViewDataSource {
    func numberOfCardsToShow() -> Int {
        return matchData?.count ?? 0
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
// MARK: Pairing judgment for left and right swipe
extension MatchVC: StackContainerViewDelegate {
    func swipeMatched(toMatch: Bool, index: Int) {
        guard let matchData = matchData else { return }
        self.updateIndex(index: index)
        if toMatch {
            searchID(user: SignVC.userData, netizen: matchData[index])
//            self.playMatchAnimation(true)
        } else {
            serachBeLike(user: SignVC.userData, netizen: matchData[index])
        }
                
        if index == matchData.count - 2 {
            fetchData()
        }
    }
}

// MARK: Location
extension MatchVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingHeading()
        }
        print("\(location.coordinate.latitude) + \(location.coordinate.longitude)")
//        self.updateLocation(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
