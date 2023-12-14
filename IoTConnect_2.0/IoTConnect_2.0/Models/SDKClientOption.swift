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
//    public var brokerType: BrokerType?{
//        didSet{
//            if brokerType == .aws{
//                enum Env:String{
//                    case a = "a"
//                    case b  = "b"
//                }
//            }else if brokerType == .az{
//                enum Env:String{
//                    case c = "a"
//                    case d  = "b"
//                }
//            }
//        }
//    }
    
    public var broker = Broker.az.EnvironmentA.dev
    
    //MARK: - Method - SDK-Initialiase
    public init () {}
}


public struct Broker {
    public struct az {
        let environment: EnvironmentA
        public enum EnvironmentA {
            case dev
            case qa
            case prod
            
//            public var rawValue: String {
//                switch self {
//                case .dev:  return "dev"
//                case .qa:  return "qa"
//                case .prod:  return "prod"
//                }
//            }
        }
    }
    
    public struct aws {
        let environment: EnvironmentA
        public enum EnvironmentA {
            case d
            case q
            case p
            
//            public var rawValue: String {
//                switch self {
//                case .d:  return "aws_dev"
//                case .q:  return "aws_qa"
//                case .p:  return "aws_prod"
//                }
//            }
        }
    }
}
