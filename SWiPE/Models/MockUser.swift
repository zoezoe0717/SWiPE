//
//  MockUser.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/19.
//

import Foundation


struct MockUser {
    static var mockUserDatas: [User] = [
        User(
            id: "",
            name: MockName.name1.rawValue,
            email: "",
            latitude: 0,
            longitude: 0,
            age: 18,
            story: MockPhoto.photo1.rawValue,
            video: MockVideo.video1.rawValue,
            introduction: MockIntroduction.introduction1.rawValue,
            createdTime: 0,
            index: ""
        ),
        
        User(
            id: "",
            name: MockName.name2.rawValue,
            email: "",
            latitude: 0,
            longitude: 0,
            age: 18,
            story: MockPhoto.photo2.rawValue,
            video: MockVideo.video2.rawValue,
            introduction: MockIntroduction.introduction2.rawValue,
            createdTime: 0,
            index: ""
        ),
        
        User(
            id: "",
            name: MockName.name3.rawValue,
            email: "",
            latitude: 0,
            longitude: 0,
            age: 18,
            story: MockPhoto.photo3.rawValue,
            video: MockVideo.video3.rawValue,
            introduction: MockIntroduction.introduction3.rawValue,
            createdTime: 0,
            index: ""
        ),
        
        User(
            id: "",
            name: MockName.name4.rawValue,
            email: "",
            latitude: 0,
            longitude: 0,
            age: 18,
            story: MockPhoto.photo4.rawValue,
            video: MockVideo.video4.rawValue,
            introduction: MockIntroduction.introduction4.rawValue,
            createdTime: 0,
            index: ""
        ),
        
        User(
            id: "",
            name: MockName.name5.rawValue,
            email: "",
            latitude: 0,
            longitude: 0,
            age: 18,
            story: MockPhoto.photo5.rawValue,
            video: MockVideo.video5.rawValue,
            introduction: MockIntroduction.introduction5.rawValue,
            createdTime: 0,
            index: ""
        ),
        
        User(
            id: "",
            name: MockName.name6.rawValue,
            email: "",
            latitude: 0,
            longitude: 0,
            age: 18,
            story: MockPhoto.photo6.rawValue,
            video: MockVideo.video6.rawValue,
            introduction: MockIntroduction.introduction6.rawValue,
            createdTime: 0,
            index: ""
        ),
        
        User(
            id: "",
            name: MockName.name7.rawValue,
            email: "",
            latitude: 0,
            longitude: 0,
            age: 18,
            story: MockPhoto.photo7.rawValue,
            video: MockVideo.video7.rawValue,
            introduction: MockIntroduction.introduction7.rawValue,
            createdTime: 0,
            index: ""
        ),
        
        User(
            id: "",
            name: MockName.name8.rawValue,
            email: "",
            latitude: 0,
            longitude: 0,
            age: 18,
            story: MockPhoto.photo8.rawValue,
            video: MockVideo.video8.rawValue,
            introduction: MockIntroduction.introduction8.rawValue,
            createdTime: 0,
            index: ""
        ),
        
        User(
            id: "",
            name: MockName.name9.rawValue,
            email: "",
            latitude: 0,
            longitude: 0,
            age: 18,
            story: MockPhoto.photo9.rawValue,
            video: MockVideo.video9.rawValue,
            introduction: MockIntroduction.introduction9.rawValue,
            createdTime: 0,
            index: ""
        ),
        
        User(
            id: "",
            name: MockName.name10.rawValue,
            email: "",
            latitude: 0,
            longitude: 0,
            age: 18,
            story: MockPhoto.photo10.rawValue,
            video: MockVideo.video10.rawValue,
            introduction: MockIntroduction.introduction10.rawValue,
            createdTime: 0,
            index: ""
        )
    ]
}

enum MockVideo: String, CaseIterable {
    case video1 = "https://i.imgur.com/NOzxvwU.mp4"
    case video2 = "https://i.imgur.com/O9omfmg.mp4"
    case video3 = "https://i.imgur.com/tIUryXg.mp4"
    case video4 = "https://i.imgur.com/BAWPWVq.mp4"
    case video5 = "https://i.imgur.com/JHW2LEZ.mp4"
    case video6 = "https://i.imgur.com/2HuQHYz.mp4"
    case video7 = "https://i.imgur.com/V5iaVCy.mp4"
    case video8 = "https://i.imgur.com/PcgYp9n.mp4"
    case video9 = "https://i.imgur.com/3HhfJO3.mp4"
    case video10 = "https://i.imgur.com/6qmF0eC.mp4"
}

enum MockPhoto: String, CaseIterable {
    case photo1 = "https://i.imgur.com/SSADow0.jpeg"
    case photo2 = "https://i.imgur.com/F2NgFBg.jpeg"
    case photo3 = "https://i.imgur.com/0OXyb26.jpeg"
    case photo4 = "https://i.imgur.com/sNZ0V4q.jpeg"
    case photo5 = "https://i.imgur.com/kHCk6eM.jpeg"
    case photo6 = "https://i.imgur.com/BkHSOfR.jpeg"
    case photo7 = "https://i.imgur.com/qlGCV9c.jpeg"
    case photo8 = "https://i.imgur.com/qMXLQlM.jpeg"
    case photo9 = "https://i.imgur.com/TvFSA9b.jpeg"
    case photo10 = "https://i.imgur.com/y9dH2bJ.jpeg"
}

enum MockName: String, CaseIterable {
    case name1 = "Steven"
    case name2 = "Riley"
    case name3 = "Hailey"
    case name4 = "Joe"
    case name5 = "Hanna"
    case name6 = "Eric"
    case name7 = "Ray"
    case name8 = "Karen"
    case name9 = "Cathy"
    case name10 = "Jessica"
}

enum MockIntroduction: String, CaseIterable {
    case introduction1 = "你好呀"
    case introduction2 = "嗨嗨嗨嗨嗨嗨嗨"
    case introduction3 = "#火鍋#愛狗"
    case introduction4 = "666666666666"
    case introduction5 = "早安晚安午安"
    case introduction6 = "喜歡追劇"
    case introduction7 = "1234567想不到8"
    case introduction8 = "嗨11111"
    case introduction9 = "我都得蒂一名"
    case introduction10 = "加油"
}
