//
//  Enums.swift
//  IoTConnectDemo
//
//  Created by kirtan.vaghela on 16/06/23.
//

import Foundation

enum statusText:String{
    case disconnected = "Device Disconnected..."
    case connected = "Device Connected.."
}

struct CommandType {
    static let DEVICE_COMMAND = 0
    static let OTA_COMMAND = 1
    static let MODULE_COMMAND = 2
    static let CORE_COMMAND = 101//"0x01"
    static let REFRESH_TWIN = 102//"0x02"
    static let REFRESH_EDGE_RULE = 103
    static let REFRESH_CHILD_DEVICE = 104
    static let DATA_FREQUENCY_CHANGE = 105
    static let ATTRIBUTE_INFO_UPDATE = 110//"0x10"
    static let SETTING_INFO_UPDATE = 111//"0x11"
    static let PASSWORD_INFO_UPDATE = 112//"0x12"
    static let DEVICE_INFO_UPDATE = 113//"0x13"
    static let RULE_INFO_UPDATE = 115//"0x15"
    static let DEVICE_CONNECTION_STATUS = 116//"0x16"
    static let DATA_FREQUENCY_UPDATE = 117//"0x17"
    static let STOP_SDK_CONNECTION = 199//"0x99"
    static let DEVICE_DELETED = 106
    static let DEVICE_DISABLED = 107
    static let DEVICE_RELEASED = 108
    static let STOP_OPERATION = 109
    static let IDENTITIY_RESPONSE = 200
    static let GET_DEVICE_TEMPLATE_ATTRIBUTE = 201
    static let GET_DEVICE_TEMPLATE_TWIN = 202
    static let GET_EDGE_RULE = 203
    static let GET_CHILD_DEVICE = 204
    static let GET_PENDING_OTAS = 205
}
