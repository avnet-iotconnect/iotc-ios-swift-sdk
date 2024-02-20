//
//  SDKClientOption.swift
//  IoTConnect
//
//  Created by Devesh Mevada on 8/20/21.
//

import Foundation

public struct SDKClientOption {
    
    //For SSL CA signed and SelfSigned authorized device only
    public var ssl = SSLOption()
    
    //For Offline Storage only
    public var offlineStorage = OfflineStorageOption()
    
    //For Developer only
    public var discoveryUrl: String?
    public var debug: Bool = false
    public var skipValidation = false
    
    //device PK
    public var devicePK = ""
    
    public let cpId: String = ""
    public var pf:IoTCPf?
    public var env: IOTCEnvironment?
       
//    public var broker = Broker.az.EnvironmentA.dev
    
    //MARK: - Method - SDK-Initialiase
    public init () {}
}

