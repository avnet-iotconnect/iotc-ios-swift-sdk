//
//  IoTData.swift
//  IoTConnect
//
//  Created by Devesh Mevada on 8/25/21.
//

import Foundation

//{"d":{"sc":{"hb":{"fq":10,"h":"","un":"","pwd":"","pub":""},"log":{"h":"","un":"","pwd":"","pub":""},"sf":0,"df":60},"p":{"n":"mqtt","h":"qa-iconnect-core-iothub-cu.azure-devices.net","p":8883,"id":"nine-ios","un":"qa-iconnect-core-iothub-cu.azure-devices.net/nine-ios/?api-version=2018-06-30","pwd":"SharedAccessSignature sr=qa-iconnect-core-iothub-cu.azure-devices.net%2Fdevices%2Fnine-ios&sig=2KGYAhE0o3gwwXz2GWtUy9JTcfvlu%2F8SRwH7WViNcbk%3D&se=1661346098","pub":"devices/nine-ios/messages/events/","sub":"devices/nine-ios/messages/devicebound/#"},"d":[{"tg":"","id":"ios"}],"att":[{"p":"","dt":null,"agt":0,"tw":"","tg":"","d":[{"ln":"temperature","dt":0,"dv":"","tg":"","sq":1,"agt":0,"tw":""},{"ln":"humidity","dt":0,"dv":"10 to 15","tg":"","sq":2,"agt":0,"tw":""}]},{"p":"gyroscope","dt":2,"agt":0,"tw":"","tg":"","d":[{"ln":"x","dt":0,"dv":"","tg":"","sq":1,"agt":0,"tw":""},{"ln":"y","dt":1,"dv":"","tg":"","sq":2,"agt":0,"tw":""},{"ln":"z","dt":0,"dv":"","tg":"","sq":3,"agt":0,"tw":""}]}],"set":[{"ln":"firmware_version","dt":0,"dv":""}],"r":null,"ota":null,"dtg":"89a2e49b-7546-45ad-a574-cde745c2f8c3","cpId":"nine","rc":0,"ee":0,"at":1,"ds":0}}

struct IoTData: Codable {
    let d: D
    
    struct D: Codable {
        let sc: SC
        let p: P
        let d: [DD]
        let att: [ATT]
        let set: [SET]
        let r: String?
        let ota: String?
        let dtg: String
        let cpId: String
        let rc: Int
        let ee: Int
        let at: Int
        let ds: Int
    }
}

struct SC: Codable {
    let hb: HB
    let log: LOG
    let sf: Int
    let df: Int
    
    struct HB: Codable {
        let fq: Int
        let h: String
        let un: String
        let pwd: String
        let pub: String
    }
    
    struct LOG: Codable {
        let h: String
        let un: String
        let pwd: String
        let pub: String
    }
}

struct P: Codable {
    let n: String
    let h: String
    let p: Int
    let id: String
    let un: String
    let pwd: String
    let pub: String
    let sub: String
}

struct DD: Codable {
    let tg: String
    let id: String
}

struct ATT: Codable {
    let p: String
    let dt: Int?
    let agt: Int
    let tw: String
    let tg: String
    let d: [ATTD]
    
    struct ATTD: Codable {
        let ln: String
        let dt: Int
        let dv: String
        let tg: String
        let sq: Int
        let agt: Int
        let tw: String
    }
}

struct SET: Codable {
    let ln: String
    let dt: Int
    let dv: String
}

