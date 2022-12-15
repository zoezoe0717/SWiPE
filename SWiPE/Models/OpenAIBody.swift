//
//  ChatGPT.swift
//  SWiPE
//
//  Created by Zoe on 2022/12/14.
//

import Foundation

struct OpenAIBody: Codable {
    let model: String
    let prompt: String
    let temperature: Double = 0.7
    let maxTokens: Int = 256
    let topP: Int = 1
    let frequencyPenalty: Int = 0
    let presencePenalty: Int = 0

    enum CodingKeys: String, CodingKey {
        case model, prompt, temperature
        case maxTokens = "max_tokens"
        case topP = "top_p"
        case frequencyPenalty = "frequency_penalty"
        case presencePenalty = "presence_penalty"
    }
}
