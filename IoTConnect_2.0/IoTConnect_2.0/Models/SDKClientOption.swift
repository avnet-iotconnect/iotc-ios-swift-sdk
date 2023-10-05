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
    
    //broker options
    public var brokerType: BrokerType?
    
    //MARK: - Method - SDK-Initialiase
    public init () {}
}
