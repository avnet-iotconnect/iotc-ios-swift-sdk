//
//  NetworkConstants.swift
//  IoTConnect
//
//  Created by Devesh Mevada on 8/23/21.
//

import Foundation

enum b:String{
    case az = "az"
    case aws = "aws"
}

class EnvironmentSelector {
    class var environment: IOTCEnvironment {
        return .PROD
    }
}

struct HTTPScheme {
    static let secure = "https"
    static let notSecure = "http"
}

struct HTTPHeaderKeys {
    static let contentType = "Content-Type"
    static let accept = "Accept"
    static let contentLength = "Content-Length"
}

struct HTTPHeaderValues {
    static let json = "application/json"
}

struct ApiConstants {
    static var BASE_URL: String {
        switch EnvironmentSelector.environment {
        default: return "discovery.iotconnect.io"
        }
    }
    
    static var DISCOVERY_PATH: String {
        switch EnvironmentSelector.environment {
        default: return "/api/sdk/cpid/"
        }
    }
    
    static var SYNC_PATH: String {
        switch EnvironmentSelector.environment {
        default: return "sync"
        }
    }
}
