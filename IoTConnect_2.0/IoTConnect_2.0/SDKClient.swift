//
//  IoTConnectSDK.swift
//  IoTConnect

import Foundation

public typealias GetDeviceCallBackBlock = (Any?) -> ()
public typealias GetTwinUpdateCallBackBlock = (Any?) -> ()
public typealias GetAttributesCallbackBlock = (Any?) -> ()
public typealias GetTwinCallBackBlock = (Any?) -> ()
public typealias GetChildDevicesCallBackBlock = (Any?) -> ()


public class SDKClient {
    // Singleton SDK object
    public static let shared = SDKClient()
    
    fileprivate var iotConnectManager: IoTConnectManager!// = IoTConnectManager.sharedInstance
    private var blockHandlerDeviceCallBack : GetDeviceCallBackBlock?
    private var blockHandlerTwinUpdateCallBack : GetTwinUpdateCallBackBlock?
    private var blockHandlerGetAttributesCallBack : GetAttributesCallbackBlock?
    private var blockHandlerGetTwinsCallBack : GetTwinCallBackBlock?
    private var blockHandlerGetChildDevicesCallBack : GetChildDevicesCallBackBlock?
    
    /**
     Initialize configuration for IoTConnect SDK
     
     - Author:
     Devesh Mevada
     
     - parameters:
     - config: Setup IoTConnectConfig
     
     - returns:
     Returns nothing
     */
    public func initialize(config: IoTConnectConfig) {
        print("SDKClient initialize")
        iotConnectManager = IoTConnectManager(cpId: config.cpId, uniqueId: config.uniqueId, env: config.env.rawValue, sdkOptions: config.sdkOptions, deviceCallback: { (message) in
            if self.blockHandlerDeviceCallBack != nil {
                print("SDKClient blockHandlerDeviceCallBack")
                self.blockHandlerDeviceCallBack!(message)
            }
        }, twinUpdateCallback: { (twinMessage) in
            if self.blockHandlerTwinUpdateCallBack != nil {
                self.blockHandlerTwinUpdateCallBack!(twinMessage)
            }
        }, attributeCallBack: { (attributesMsg) in
            if self.blockHandlerGetAttributesCallBack != nil{
                self.blockHandlerGetAttributesCallBack!(attributesMsg)
            }
        }, twinsCallBack: { (twinsMsg) in
            if self.blockHandlerGetTwinsCallBack != nil{
                self.blockHandlerGetTwinsCallBack!(twinsMsg)
            }
        }, getChildCallback: { (msg) in
            if self.blockHandlerGetChildDevicesCallBack != nil{
                self.blockHandlerGetChildDevicesCallBack!(msg)
            }
        })
    }
    
    /**
     Used for sending data from Device to Cloud
     
     - Author:
     Devesh Mevada
     
     - parameters:
     - data: Provide data in [[String:Any]] format
     
     - returns:
     Returns nothing
     */
    public func sendData(data: [String:Any]) {
        iotConnectManager.sendData(data: data)
    }
    
    /**
     Used for sending log from device to cloud
     
     - Author:
     Devesh Mevada
     
     - parameters:
     - data: send log in [String: Any] format
     
     - returns:
     Returns nothing
     */
    public func sendLog(data: [String: Any]?) {
        iotConnectManager.sendLog(data: data)
    }
    
    /**
     Send acknowledgement signal
     
     - Author:
     Devesh Mevada
     
     - parameters:
     - data: send data in [[String:Any]] format
     - msgType: send msgType from anyone of this
     
     - returns:
     Returns nothing
     */
    public func sendAck(data: [[String:Any]], msgType: String) {
        iotConnectManager.sendAck(data: data, msgType: msgType)
    }
    
    public func sendAckCmd(ackGuid:String,status:String, msg:String = "",childId:String = "") {
        iotConnectManager.sendAckCmd(ackGuid: ackGuid, status: status,msg: msg,childId: childId)
    }
    
    /**
     Get all twins
     
     - Author:
     Devesh Mevada
     
     - returns:
     Returns nothing
     */
    public func getAllTwins() {
        iotConnectManager.getAllTwins()
    }
    
    /**
     Updated twins
     
     - Author:
     Devesh Mevada
     
     - parameters:
     - key: key in String format
     - value: value as any
     
     - returns:
     Returns nothing
     */
    public func updateTwin(key: String, value: Any) {
        iotConnectManager.updateTwin(key: key, value: value)
    }
    
    /**
     Dispose description
     
     - Author:
     Devesh Mevada
     
     - parameters:
     - sdkconnection: description
     
     - returns:
     Returns nothing
     */
    public func dispose(sdkconnection: String = "") {
        iotConnectManager.dispose(sdkconnection: sdkconnection)
    }
    
    /**
     Get attaributs
     
     - Author:
     Devesh Mevada
     
     - parameters:
     - callBack:
     
     - returns:
     Returns nothing
     */
    public func getAttributes(callBack: @escaping GetAttributesCallbackBlock) -> () {
        blockHandlerGetAttributesCallBack = callBack
        iotConnectManager?.getAttributes(callBack: callBack)
    }
    
    public func getTwins(callBack: @escaping GetTwinCallBackBlock) -> () {
        blockHandlerGetTwinsCallBack = callBack
        iotConnectManager.getTwins(callBack: callBack)
    }
    
    public func getChildDevices(callBack: @escaping GetChildDevicesCallBackBlock) -> () {
        blockHandlerGetChildDevicesCallBack = callBack
        iotConnectManager.getChildDevices(callBack: callBack)
    }
    
    
    /**
     Get device callback
     
     - Author:
     Keyur Prajapati
     
     - parameters:
     - callBack:
     
     - returns:
     Returns nothing
     */
    public func getDeviceCallBack(deviceCallback: @escaping GetDeviceCallBackBlock) -> () {
        blockHandlerDeviceCallBack = deviceCallback
    }
    
    /**
     Get twin callback
     
     - Author:
     Keyur Prajapati
     
     - parameters:
     - callBack:
     
     - returns:
     Returns nothing
     */
    public func getTwinUpdateCallBack(twinUpdateCallback: @escaping GetTwinUpdateCallBackBlock) -> () {
        
        blockHandlerTwinUpdateCallBack = twinUpdateCallback
    }
}
