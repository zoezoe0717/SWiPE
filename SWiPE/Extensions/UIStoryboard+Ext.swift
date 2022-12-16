//
//  UIStoryboard+Ext.swift
//  SWiPE
//
//  Created by Zoe on 2022/12/7.
//

import UIKit

private enum StoryboardCategory {
    static let main = "Main"
}

extension UIStoryboard {
    static var main: UIStoryboard { return stStoryBoard(name: StoryboardCategory.main) }
    
    private static func stStoryBoard(name: String) -> UIStoryboard {
        return UIStoryboard(name: name, bundle: nil)
    }
}
