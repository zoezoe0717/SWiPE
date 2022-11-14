//
//  MatchVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/10/31.
//

import UIKit
import CoreLocation

class MatchVC: UIViewController {
    var mockUserData = User(
        id: ChatManager.mockId,
        name: "Zoe",
        email: "123@gmail.com",
        latitude: 0,
        longitude: 0,
        age: 20,
        story: "https://i.imgur.com/4Vc3NZR.png",
        video: "https://i.imgur.com/1NLECXT.mp4",
        introduction: "嘻嘻嘻嘻嘻嘻",
        createdTime: 0,
        index: 0
    )
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fullScreen = UIScreen.main.bounds.size
        configureStackContainer()
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = CustomColor.base.color
        stackContainer = StackContainerView()
        guard let stackContainer = stackContainer else { return }
        view.addSubview(stackContainer)
        stackContainer.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
     
    private func configureStackContainer() {
        guard let stackContainer = stackContainer,
              let fullScreen = fullScreen else { return }

        stackContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        stackContainer.widthAnchor.constraint(equalToConstant: fullScreen.width * 0.95).isActive = true
        stackContainer.heightAnchor.constraint(equalToConstant: fullScreen.height * 0.75).isActive = true
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
        let query = FirestoreEndpoint.users.ref.whereField("id", isNotEqualTo: ChatManager.mockId)
        FireBaseManager.shared.getDocument(query: query) { [weak self] (users: [User]) in
            guard let `self` = self else { return }
            
            self.matchData = users
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
            case .success(let success):
                print(success)
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
        if toMatch {
            self.searchID(user: AddDataVC.newUser, netizen: matchData[index])
        } else {
            self.serachBeLike(user: AddDataVC.newUser, netizen: matchData[index])
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
        print("\(location.coordinate.latitude)+ \(location.coordinate.longitude)")
//        self.updateLocation(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
