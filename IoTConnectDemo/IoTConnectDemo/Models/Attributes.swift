//
//  Attributes.swift
//  IoTConnectDemo
//
//  Created by kirtan.vaghela on 19/10/23.
//

import Foundation

struct Att: Codable {
    let p: String?
    let dt: Int?
    let agt: Int?
    let tw, tg: String?
    var d: [AttD]?
}

struct AttD: Codable {
    let ln: String?
    let dt: Int?
    let dv, tg: String?
    let sq, agt: Int?
    let tw: String?
    var p,value: String?
}
