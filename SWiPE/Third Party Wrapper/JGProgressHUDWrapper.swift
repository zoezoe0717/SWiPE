//
//  JGProgressHUDWrapper.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/21.
//

import JGProgressHUD

enum HUDType {
    case success(String)

    case failure(String)
}

class ProgressHUD {
    static let shared = ProgressHUD()

    private init() { }

    let hud = JGProgressHUD(style: .dark)
    
    var view: UIView {
        let scene = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first { $0 is UIWindowScene } as? UIWindowScene
        
        let window = scene?.windows.first { $0.isKeyWindow }
        var presentedViewController = window?.rootViewController
        while presentedViewController?.presentedViewController != nil {
            presentedViewController = presentedViewController?.presentedViewController
        }
        
        guard let view = presentedViewController?.view else { fatalError("Error: `1 qCan not find view") }
        
        return view
    }

    static func show(type: HUDType) {
        switch type {
        case .success(let text):

            showSuccess(text: text)

        case .failure(let text):

            showFailure(text: text)
        }
    }

    static func showSuccess(text: String = "success") {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                showSuccess(text: text)
            }

            return
        }

        shared.hud.textLabel.text = text

        shared.hud.indicatorView = JGProgressHUDSuccessIndicatorView()

        shared.hud.show(in: shared.view)

        shared.hud.dismiss(afterDelay: 1.5)
    }

    static func showFailure(text: String = "Failure") {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                showFailure(text: text)
            }

            return
        }

        shared.hud.textLabel.text = text

        shared.hud.indicatorView = JGProgressHUDErrorIndicatorView()

        shared.hud.show(in: shared.view)

        shared.hud.dismiss(afterDelay: 1.5)
    }

    static func show() {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                show()
            }

            return
        }

        shared.hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()

        shared.hud.textLabel.text = "Loading"

        shared.hud.show(in: shared.view)
    }

    static func dismiss() {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                dismiss()
            }

            return
        }

        shared.hud.dismiss()
    }
}

extension UIViewController {
    static func getLastPresentedViewController() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first { $0 is UIWindowScene } as? UIWindowScene
        let window = scene?.windows.first { $0.isKeyWindow }
        var presentedViewController = window?.rootViewController
        while presentedViewController?.presentedViewController != nil {
            presentedViewController = presentedViewController?.presentedViewController
        }
        return presentedViewController
    }
}
