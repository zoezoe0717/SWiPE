//
//  JSONObject.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/30.
//

import Foundation

struct JSONObject {
    static let shared = JSONObject()
    // JSON String轉Dictionary
    func toDictionary(jsonString: String) -> [String: Any] {
        guard
            let jsonData = jsonString.data(using: .utf8),
            let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers),
                let result = dict as? [String: Any] else {
            return [:]
        }
        return result
    }
}
