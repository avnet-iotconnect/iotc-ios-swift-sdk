//
//  IoTConnectService.swift
//  IoTConnect
//
//  Created by Devesh Mevada on 8/20/21.
//

import Foundation
import UIKit

extension IoTConnectManager {
    
    //MARK: - Instance Methods
    
    /**
    - initialize IoTConnectManager
     
    - parameters:
        - cpId: comoany ID
        - uniqueId:Device unique identifier
        - deviceCallback
        - twinUpdateCallback
    
     - Returns
        returns nothing
     */
    func initialize(cpId: String, uniqueId: String, deviceCallback: @escaping GetDeviceCallBackBlock, twinUpdateCallback: @escaping GetDeviceCallBackBlock, getAttributesCallback: @escaping GetAttributesCallbackBlock, getTwinsCallback: @escaping GetTwinCallBackBlock, getChildDevucesCallback: @escaping GetChildDevicesCallBackBlock) {
        dictReference = [:]
        dictSyncResponse = [:]
        blockHandlerDeviceCallBack = deviceCallback
        blockHandlerTwinUpdateCallBack = twinUpdateCallback
        blockHandlerGetAttribuesCallBack = getAttributesCallback
        blockHandlerGetTwinsCallBack = getTwinsCallback
        blockHandlerGetChildDevicesCallback = getChildDevucesCallback
        boolCanCallInialiseYN = true
        objCommon.createDirectoryFoldersForLogs()
        objCommon.manageDebugLog(code: Log.Info.INFO_IN04, uniqueId: uniqueId, cpId: cpId, message: "", logFlag: true, isDebugEnabled: boolDebugYN)
        objCommon.getBaseURL(strURL: SDKURL.discovery(strDiscoveryURL, cpId, SDKConstants.Language, SDKConstants.Version, strEnv.rawValue)) { (status, data) in
            if status {
                if let dataRef = data as? [String : Any] {
                    self.objCommon.manageDebugLog(code: Log.Info.INFO_IN07, uniqueId: uniqueId, cpId: cpId, message: "", logFlag: true, isDebugEnabled: self.boolDebugYN)
                    self.dictReference = dataRef
                    if self.dictReference[keyPath:"d.ec"] as! Int == 0{
                        self.initaliseCall(uniqueId: uniqueId)
                    }else{
                        let errorDict = ["error":Log.getAPIErrorMsg(errorCode: self.dictReference[keyPath:"d.ec"] as? Int ?? 15)]
                        deviceCallback(errorDict)
                        self.objCommon.manageDebugLog(code: self.dictReference[keyPath:"d.ec"] ?? 15, uniqueId: uniqueId, cpId: cpId, message: "", logFlag: false, isDebugEnabled: self.boolDebugYN)
                    }
                } else {
                    self.objCommon.manageDebugLog(code: Log.Errors.ERR_IN09, uniqueId: uniqueId, cpId: cpId, message: "", logFlag: false, isDebugEnabled: self.boolDebugYN)
                }
            } else {
                if let error = data as? Error {
                    self.objCommon.manageDebugLog(code: Log.Errors.ERR_IN01, uniqueId: uniqueId, cpId: cpId, message: error.localizedDescription, logFlag: false, isDebugEnabled: self.boolDebugYN)
                }
            }
        }
    }
    
    /**
    - initialize initaliseCall
     
    - parameters:
        - uniqueId:Device unique identifier
      
     - Returns
        returns nothing
     */
    
    private func initaliseCall( uniqueId: String) {
        if boolCanCallInialiseYN {
            boolCanCallInialiseYN = false
            dictSyncResponse.removeAll()
            //kirtan
            let bu = dictReference[keyPath:"d.bu"]//d?["bu"]
            objCommon.makeSyncCall(withBaseURL: (bu as? String ?? "") + "/uid/"+"\(uniqueId)", withData: [DeviceSync.Request.cpId: strCPId as Any, DeviceSync.Request.uniqueId: strUniqueId as Any, DeviceSync.Request.option: [DeviceSync.Request.attribute: true, DeviceSync.Request.setting: true, DeviceSync.Request.protocolKey: true, DeviceSync.Request.device: true, DeviceSync.Request.sdkConfig: true, DeviceSync.Request.rule: true]]) { (data, response, error) in
                
                self.blockHandlerDeviceCallBack?(data)
                if error == nil {
                    let errorParse: Error? = nil
         
                    let dataDeviceTemp = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    
                    
                    if dataDeviceTemp == nil {
                        
                        print("Error parsing DSC: \(String(describing: errorParse))")
                        self.objCommon.manageDebugLog(code: Log.Errors.ERR_PS01, uniqueId: self.strUniqueId, cpId: self.strCPId, message: errorParse?.localizedDescription ?? "", logFlag: false, isDebugEnabled: self.boolDebugYN)
                        self.blockHandlerDeviceCallBack(["sdkStatus": "error"])
                    } else {
                        let dataDevice = dataDeviceTemp as! [String:Any]
                       
                        if let jsonData = try? JSONDecoder().decode(Identity.self, from: data!) {
                            self.identity = jsonData
                        } else {
                          print("Error parsing syncCall Response")
                        }
                        if dataDevice["d"] != nil {
                            self.objCommon.manageDebugLog(code: Log.Info.INFO_IN01, uniqueId: self.strUniqueId, cpId: self.strCPId, message: "", logFlag: true, isDebugEnabled: self.boolDebugYN)
                            print("identity pos data\(String(describing: self.identity?.d?.has))")
                            if SDKConstants.DevelopmentSDKYN {
                                print("blockHandlerDeviceCallBack initialise call \(dataDevice)")
                                self.blockHandlerDeviceCallBack(["sdkStatus": "success", "data": dataDevice["d"]])
                            }
                            if dataDevice[keyPath:"d.ec"] as! Int == DeviceSync.Response.OK {//...OK
                                
                                if !self.dataSDKOptions.OfflineStorage.Disabled {
                                    self.objCommon.createPredeffinedLogDirecctories(folderName: "logs/offline/\(self.strCPId!)_\(self.strUniqueId!)")
                                }
                                
                                self.objCommon.manageDebugLog(code: Log.Info.INFO_IN08, uniqueId: self.strUniqueId, cpId: self.strCPId, message: "", logFlag: true, isDebugEnabled: self.boolDebugYN)
                                
                                if self.timerNotRegister != nil {
                                    self.timerNotRegister?.invalidate()
                                    self.timerNotRegister = nil
                                }
                              
                                
                                self.dictSyncResponse = dataDevice["d"] as? [String : Any]
//                                self.getAttributes { isSuccess, data, msg in
//
//                                }
                                let metaInfo = self.dictSyncResponse["meta"] as? [String:Any]
                                
                                if metaInfo?["at"] as! Int == AuthType.CA_SIGNED || metaInfo?["at"] as! Int == AuthType.CA_SELF_SIGNED && !self.CERT_PATH_FLAG {
                                    
                                    self.objCommon.manageDebugLog(code: Log.Errors.ERR_IN06, uniqueId: self.strUniqueId, cpId: self.strCPId, message: "", logFlag: false, isDebugEnabled: self.boolDebugYN)
                                    
                                } else {
                                    
                                    if (dataDevice[keyPath: "d.p.n"] as! String).lowercased() == SDKConstants.protocolMQTT {
                                        //...Here
                                        self.startMQTTCall(dataSyncResponse: self.dictSyncResponse)
                                    } else if (dataDevice[keyPath: "d.p.n"] as! String).lowercased() == SDKConstants.protocolHTTP {
                                        
                                    } else if (dataDevice[keyPath: "d.p.n"] as! String).lowercased() == SDKConstants.protocolAMQP {
                                        
                                    }
                                    
                                }
                                
                            } else if dataDevice[keyPath:"d.ec"] as! Int == DeviceSync.Response.DEVICE_NOT_REGISTERED {//...Not Register
                                let errorDict = ["error":Log.getAPIErrorMsg(errorCode: dataDevice[keyPath:"d.ec"] as? Int ?? 15)]
                                self.blockHandlerDeviceCallBack(errorDict)
                                self.objCommon.manageDebugLog(code: Log.Info.INFO_IN09, uniqueId: self.strUniqueId, cpId: self.strCPId, message: "", logFlag: true, isDebugEnabled: self.boolDebugYN)
                                
                                if self.timerNotRegister == nil {
                                    var dblSyncFrequency = SDKConstants.FrequencyDSC
                                    if let dblSyncFrequencyTemp = dataDevice[keyPath:"d.sc.sf"] as? Double {
                                        dblSyncFrequency = dblSyncFrequencyTemp
                                    }
                                    self.startTimerForReInitialiseDSC(durationSyncFrequency: dblSyncFrequency)
                                }
                                
                            } else if dataDevice[keyPath:"d.ec"] as! Int == DeviceSync.Response.AUTO_REGISTER {//...Auto Register
                                let errorDict = ["error":Log.getAPIErrorMsg(errorCode: dataDevice[keyPath:"d.ec"] as? Int ?? 15)]
                                self.blockHandlerDeviceCallBack(errorDict)
                                self.objCommon.manageDebugLog(code: Log.Info.INFO_IN10, uniqueId: self.strUniqueId, cpId: self.strCPId, message: "", logFlag: true, isDebugEnabled: self.boolDebugYN)
                                
                            } else if dataDevice[keyPath:"d.ec"] as! Int == DeviceSync.Response.DEVICE_NOT_FOUND {//...Not Found
                                let errorDict = ["error":Log.getAPIErrorMsg(errorCode: dataDevice[keyPath:"d.ec"] as? Int ?? 15)]
                                self.blockHandlerDeviceCallBack(errorDict)
                                self.objCommon.manageDebugLog(code: Log.Info.INFO_IN11, uniqueId: self.strUniqueId, cpId: self.strCPId, message: "", logFlag: true, isDebugEnabled: self.boolDebugYN)
                                
                                if self.timerNotRegister == nil {
                                    var dblSyncFrequency = SDKConstants.FrequencyDSC
                                    if let dblSyncFrequencyTemp = dataDevice[keyPath:"d.sc.sf"] as? Double {
                                        dblSyncFrequency = dblSyncFrequencyTemp
                                    }
                                    self.startTimerForReInitialiseDSC(durationSyncFrequency: dblSyncFrequency)
                                }
                                
                            } else if dataDevice[keyPath:"d.ec"] as! Int == DeviceSync.Response.DEVICE_INACTIVE {//...Inactive
                                let errorDict = ["error":Log.getAPIErrorMsg(errorCode:  dataDevice[keyPath:"d.ec"] as? Int ?? 15)]
                                self.blockHandlerDeviceCallBack(errorDict)
                                self.objCommon.manageDebugLog(code: Log.Info.INFO_IN12, uniqueId: self.strUniqueId, cpId: self.strCPId, message: "", logFlag: true, isDebugEnabled: self.boolDebugYN)
                                
                                if self.timerNotRegister == nil {
                                    var dblSyncFrequency = SDKConstants.FrequencyDSC
                                    if let dblSyncFrequencyTemp = dataDevice[keyPath:"d.sc.sf"] as? Double {
                                        dblSyncFrequency = dblSyncFrequencyTemp
                                    }
                                    self.startTimerForReInitialiseDSC(durationSyncFrequency: dblSyncFrequency)
                                }
                                
                            } else if dataDevice[keyPath:"d.ec"] as! Int == DeviceSync.Response.OBJECT_MOVED {//...Discovery URL
                                let errorDict = ["error":Log.getAPIErrorMsg(errorCode: dataDevice[keyPath:"d.ec"] as? Int ?? 15)]
                                self.blockHandlerDeviceCallBack(errorDict)
                                self.objCommon.manageDebugLog(code: Log.Info.INFO_IN13, uniqueId: self.strUniqueId, cpId: self.strCPId, message: "", logFlag: true, isDebugEnabled: self.boolDebugYN)
                                
                            } else if dataDevice[keyPath:"d.ec"] as! Int == DeviceSync.Response.CPID_NOT_FOUND {//...CPID Not Found
                                let errorDict = ["error":Log.getAPIErrorMsg(errorCode: dataDevice[keyPath:"d.ec"] as? Int ?? 15)]
                                self.blockHandlerDeviceCallBack(errorDict)
                                self.objCommon.manageDebugLog(code: Log.Info.INFO_IN14, uniqueId: self.strUniqueId, cpId: self.strCPId, message: "", logFlag: true, isDebugEnabled: self.boolDebugYN)
                                
                            } else {
                                let errorDict = ["error":Log.getAPIErrorMsg(errorCode: dataDevice[keyPath:"d.ec"] as? Int ?? 15)]
                                self.blockHandlerDeviceCallBack(errorDict)
////                                deviceCallback(errorDict)
//
//                                self.objCommon.manageDebugLog(code: self.dictReference[keyPath:"d.ec"] ?? 15, uniqueId: uniqueId, cpId: cpId, message: "", logFlag: false, isDebugEnabled: self.boolDebugYN)
                                
                                self.objCommon.manageDebugLog(code: Log.Info.INFO_IN15, uniqueId: self.strUniqueId, cpId: self.strCPId, message: "", logFlag: true, isDebugEnabled: self.boolDebugYN)
                                
                            }
                            
                        } else {
                            
                            self.objCommon.manageDebugLog(code: Log.Errors.ERR_IN10, uniqueId: self.strUniqueId, cpId: self.strCPId, message: "", logFlag: false, isDebugEnabled: self.boolDebugYN)
                            
                        }
                    }
                } else {
                    
                    print("Error parsing DSC: \(String(describing: error))")
                    self.objCommon.manageDebugLog(code: Log.Errors.ERR_IN01, uniqueId: self.strUniqueId, cpId: self.strCPId, message: error!.localizedDescription, logFlag: false, isDebugEnabled: self.boolDebugYN)
                
                    if SDKConstants.DevelopmentSDKYN {
                        self.blockHandlerDeviceCallBack(["sdkStatus": "error"])
                    }
                    
                }
                
                self.boolCanCallInialiseYN = true
            }
        }
    }
    
    /**
    -start Timer For ReInitialiseDSC
     
    - parameters:
        - durationSyncFrequency: timeInterval as double
      
     - Returns
        returns nothing
     */
    private func startTimerForReInitialiseDSC(durationSyncFrequency: Double) {
        self.repeatTimerCount = 0
        self.timerNotRegister = Timer(timeInterval: durationSyncFrequency, target: self, selector: #selector(self.reInitialise), userInfo: nil, repeats: true)
        RunLoop.main.add(self.timerNotRegister!, forMode: .default)
        self.timerNotRegister!.fire()
    }
    @objc private func reInitialise() {
        if self.repeatTimerCount < 5{
            print("reInitialise")
            self.repeatTimerCount += 1
            self.objCommon.manageDebugLog(code: Log.Info.INFO_IN06, uniqueId: strUniqueId, cpId: strCPId, message: "", logFlag: true, isDebugEnabled: self.boolDebugYN)
            initaliseCall(uniqueId: strUniqueId)
        }else{
            if self.timerNotRegister != nil {
                self.timerNotRegister?.invalidate()
                self.timerNotRegister = nil
            }
        }
    }
    
    /**
    -startMQTTCall
     
    - parameters:
        - dataSyncResponse:  data as [String:Any] format
      
     - Returns
        returns nothing
     */
    private func startMQTTCall(dataSyncResponse: [String:Any]) {
        if dataSyncResponse["p"] != nil {
            
            self.objCommon.manageDebugLog(code: Log.Info.INFO_IN05, uniqueId: strUniqueId, cpId: strCPId, message: "", logFlag: true, isDebugEnabled: boolDebugYN)
//            startEdgeDeviceProcess(dictSyncResponse: dataSyncResponse)
            self.objMQTTClient.initiateMQTT(dictSyncResponse: dataSyncResponse) { (dataToPass, typeAction) in
                
                //typeAction == 1   //...For Development Call Back
                //typeAction == 2   //...For Device Command Fire
                //typeAction == 3   //...For Updated Sync Response
                //typeAction == 4   //...For Get Desired and Reported twin property
                //typeAction == 5   //...For Get All Twin Property
                //typeAction == 6   //...For Perform Dispose
                //typeAction == 7   //...For Device attribute
                //typeAction == 8   //...For Device twins
                //typeAction == 9   //...For Getting child devices
                //typeAction == 10  //...For Getting Edge rules
                
                if typeAction == 1 {
                    if let dataMessage = dataToPass as? [String:Any] {
                        if let strMsgStatus = dataMessage["sdkStatus"] as? String {
                            if strMsgStatus == "connect" {
                            } else if strMsgStatus == "error" {
                            } else if strMsgStatus == "success" {
                            }
                        }
                    }
                }
                
                if (typeAction == 1 && SDKConstants.DevelopmentSDKYN) || typeAction == 2 {
                    self.blockHandlerDeviceCallBack(dataToPass)
                } else if typeAction == 3 {
                    self.getUpdatedSyncResponseFor(strKey: dataToPass as! Int)
                } else if typeAction == 4 {
                    var dataTwin: [String:Any] = [:]
                    dataTwin["desired"] = dataToPass
                    dataTwin["uniqueId"] = self.strUniqueId
                    self.blockHandlerTwinUpdateCallBack(dataTwin)
                } else if typeAction == 5 {
                    var dataTwin: [String:Any] = dataToPass as! [String : Any]
                    dataTwin["uniqueId"] = self.strUniqueId
                    self.blockHandlerTwinUpdateCallBack(dataTwin)
                } else if typeAction == 6 {
                    self.dispose(sdkconnection: dataToPass as! String)
                }else if typeAction == 7{
                    print("Did recive 201 startMQTTCall")
                    self.startEdgeDeviceProcess(dictSyncResponse: self.dictSyncResponse)
                    self.blockHandlerDeviceCallBack(dataToPass)
                    self.blockHandlerGetAttribuesCallBack(dataToPass)
                }
                else if typeAction == 8{
                    self.blockHandlerDeviceCallBack(dataToPass)
                    self.blockHandlerGetTwinsCallBack(dataToPass)
                }
                else if typeAction == 9{
                    self.blockHandlerDeviceCallBack(dataToPass)
                    self.blockHandlerGetChildDevicesCallback(dataToPass)
                }  else if typeAction == 10{
                    print("Edge rule match \(String(describing: dataToPass))")
//                    self.blockHandlerDeviceCallBack(dataToPass)
//                    self.blockHandlerGetChildDevicesCallback(dataToPass)
                }
            }
        } else {
            self.objCommon.manageDebugLog(code: Log.Errors.ERR_IN11, uniqueId: strUniqueId, cpId: strCPId, message: "", logFlag: false, isDebugEnabled: boolDebugYN)
        }
    }
    
    /**
    - parameters:
        - strkey:  key in string format
      
     - Returns
        returns nothing
     */
    private func getUpdatedSyncResponseFor(strKey: Int) {
        var dict: [String:Any]?
        if strKey == CommandType.ATTRIBUTE_INFO_UPDATE {//...AttributeChanged
            dict = [DeviceSync.Request.cpId: strCPId as Any, DeviceSync.Request.uniqueId: strUniqueId as Any, DeviceSync.Request.option: [DeviceSync.Request.attribute: true]]
        } else if strKey == CommandType.SETTING_INFO_UPDATE {//...SettingChanged
            dict = [DeviceSync.Request.cpId: strCPId as Any, DeviceSync.Request.uniqueId: strUniqueId as Any, DeviceSync.Request.option: [DeviceSync.Request.setting: true]]
        } else if strKey == CommandType.PASSWORD_INFO_UPDATE {//...PasswordChanged
            dict = [DeviceSync.Request.cpId: strCPId as Any, DeviceSync.Request.uniqueId: strUniqueId as Any, DeviceSync.Request.option: [DeviceSync.Request.protocolKey: true]]
        } else if strKey == CommandType.DEVICE_INFO_UPDATE {//...DeviceChanged
            dict = [DeviceSync.Request.cpId: strCPId as Any, DeviceSync.Request.uniqueId: strUniqueId as Any, DeviceSync.Request.option: [DeviceSync.Request.device: true]]
        } else if strKey == CommandType.DATA_FREQUENCY_UPDATE {//...DataFrequencyUpdated
            dict = [DeviceSync.Request.cpId: strCPId as Any, DeviceSync.Request.uniqueId: strUniqueId as Any, DeviceSync.Request.option: [DeviceSync.Request.sdkConfig: true]]
        }
        if dict != nil {
            //kirtan
            let bu = dictReference[keyPath:"d.bu"]
            objCommon.makeSyncCall(withBaseURL: bu as! String + "sync", withData: dict) { (data, response, error) in
                if error == nil {
                    let errorParse: Error? = nil
                    let dataDeviceTemp = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    if dataDeviceTemp == nil {
                        print("Error parsing Sync Call: \(String(describing: errorParse))")
                        self.objCommon.manageDebugLog(code: Log.Errors.ERR_PS01, uniqueId: self.strUniqueId, cpId: self.strCPId, message: errorParse?.localizedDescription ?? "", logFlag: false, isDebugEnabled: self.boolDebugYN)
                    } else {
                        print("Success Sync Call: \(String(describing: dataDeviceTemp))")
                        
                        let dataDevice = dataDeviceTemp as! [String:Any]
                        
                        if dataDevice["d"] != nil {
                            
                            self.objCommon.manageDebugLog(code: Log.Info.INFO_IN01, uniqueId: self.strUniqueId, cpId: self.strCPId, message: "", logFlag: true, isDebugEnabled: self.boolDebugYN)
                            
                            if dataDevice[keyPath:"d.rc"] as! Int == DeviceSync.Response.OK {
                                var dictToUpdate = self.dictSyncResponse
                                if strKey == CommandType.ATTRIBUTE_INFO_UPDATE {
                                    dictToUpdate?["att"] = dataDevice[keyPath:"d.att"]
                                } else if strKey == CommandType.SETTING_INFO_UPDATE {
                                    dictToUpdate?["set"] = dataDevice[keyPath:"d.set"]
                                } else if strKey == CommandType.PASSWORD_INFO_UPDATE {
                                    dictToUpdate?["p"] = dataDevice[keyPath:"d.p"]
                                    if dictToUpdate != nil {
                                        self.startMQTTCall(dataSyncResponse: dictToUpdate!)
                                    } else {
                                        self.objCommon.manageDebugLog(code: Log.Errors.ERR_IN11, uniqueId: self.strUniqueId, cpId: self.strCPId, message: "", logFlag: false, isDebugEnabled: self.boolDebugYN)
                                    }
                                } else if strKey == CommandType.DEVICE_INFO_UPDATE {
                                    dictToUpdate?["d"] = dataDevice[keyPath:"d.d"]
                                } else if strKey == CommandType.DATA_FREQUENCY_UPDATE {
                                    dictToUpdate?["sc"] = dataDevice[keyPath:"d.sc"]
                                }
                                if dictToUpdate != nil {
                                    self.dictSyncResponse = dictToUpdate
                                }
                            }
                            
                        } else {
                            
                            self.objCommon.manageDebugLog(code: Log.Errors.ERR_IN10, uniqueId: self.strUniqueId, cpId: self.strCPId, message: "", logFlag: false, isDebugEnabled: self.boolDebugYN)
                            
                        }
                    }
                } else {
                    print("Error parsing Sync Call: \(String(describing: error))")
                    self.objCommon.manageDebugLog(code: Log.Errors.ERR_IN01, uniqueId: self.strUniqueId, cpId: self.strCPId, message: error!.localizedDescription, logFlag: false, isDebugEnabled: self.boolDebugYN)
                }
            }
        }
    }
    
    //MARK: - SendData: Logic Methods
    /**
    -set data format to send on MQTT
     
    - parameters:
        - data:  data in [String:Any] format
      
     - Returns
        returns nothing
     */
    func setSendDataFormat(data: [[String:Any]]) {
        let timeNow = objCommon.now()
        let dict = dictSyncResponse!
        for d: [String: Any] in data  {
            autoreleasepool {
                let uniqueIds = dict["d"].flatMap{($0 as! [[String:Any]]).map { $0["id"] }} as! [String]
                if uniqueIds.contains(d["uniqueId"] as! String) {
                    let dictData = loadDataToSendIoTHub(fromSDKInput: d, withData: dict, withTime: d["time"] as! String)
                    if (dictData["rptdata"] as! [String:Any]).count > 0 {
                        var dictRptResult = [String: Any]()
                        dictRptResult["cpId"] = dict["cpId"]
                        dictRptResult["dtg"] = dict["dtg"]
                        dictRptResult["t"] = timeNow
                        dictRptResult["mt"] = MessageType.rpt
                        dictRptResult["d"] = [dictData["rptdata"]]
                        dictRptResult["sdk"] = ["l": SDKConstants.Language, "v": SDKConstants.Version, "e": strEnv.rawValue]
                        print("If-dictRptResult)")
                        objMQTTClient.publishTopicOnMQTT(withData: dictRptResult, topic: "")
                    } else {
                        print("Else-dictRptResult")
                    }
                    if (dictData["faultdata"] as! [String:Any]).count > 0 {
                        var dictFaultResult = [String: Any]()
                        dictFaultResult["cpId"] = dict["cpId"]
                        dictFaultResult["dtg"] = dict["dtg"]
                        dictFaultResult["t"] = timeNow
                        dictFaultResult["mt"] = MessageType.flt
                        dictFaultResult["d"] = [dictData["faultdata"]]
                        dictFaultResult["sdk"] = ["l": SDKConstants.Language, "v": SDKConstants.Version, "e": strEnv.rawValue]
                        print("If-dictFaultResult");
                        objMQTTClient.publishTopicOnMQTT(withData: dictFaultResult, topic: "")
                    } else {
                        print("Else-dictFaultResult")
                    }
                } else {
                    print("UniqueId not exist in 'devices'")
                }
            }
        }
    }
    /**
    load data to send on MQTT
     
    - parameters:
        - dictSDKInput:  data in [String:Any] format
        - dictSaved:
        - timeInput:
      
     - Returns
        returns data in [String: Any] format
     */
    private func loadDataToSendIoTHub(fromSDKInput dictSDKInput: [String: Any], withData dictSaved: [String: Any], withTime timeInput: String) -> [String: Any] {
        var dictDevice = [String : Any]()
        let uniqueIds = dictSaved["d"].flatMap{($0 as! [[String:Any]]).map { $0["id"] }} as! [String]
        if let index = uniqueIds.firstIndex(where: {$0  == dictSDKInput["uniqueId"] as! String}) {
            dictDevice = (dictSaved["d"] as! [[String:Any]])[index]
        }
        
        var dictCommonAttribute: [String : Any]?
        for dictAttribute  in (dictSaved["att"] as! [[String:Any]]) {
            if dictAttribute["p"] as! String == "" {
                dictCommonAttribute = dictAttribute
            }
        }
        
        var dictFaultAttributeData: [String:Any] = [:]
        var dictRptAttributeData: [String:Any] = [:]
        
        for strKey in (dictSDKInput["data"] as! [String:Any]).keys {
            var arrayFltAttrData:[[String:Any]] = []
            var arrayRptAttrData:[[String:Any]] = []
            var dictSelectAttribute: [String:Any]?
            
            for dictAttribute: [String: Any] in (dictSaved["att"] as! [[String: Any]])  {
                //Will Check for if attribute has parent or not with tag validation
                if (dictAttribute["p"] as! String == strKey) && (dictAttribute["tg"] as! String  == dictDevice["tg"] as! String) {
                    dictSelectAttribute = dictAttribute
                }
            }
            
            if dictSelectAttribute != nil {//Attribute has parent
                print("Attribute is parent")
                var arrayFltTmp:[[String:Any]] = []
                var arrayRptTmp:[[String:Any]] = []
                let strkeyPathM = KeyPath("data.\(strKey)")
                for strKeyChild: String in (dictSDKInput[keyPath:strkeyPathM] as! [String:Any]).keys {
                    let strkeyPath = KeyPath("data.\(strKey).\(strKeyChild)")
                    let dictForm = getAttributeForm(with: dictSelectAttribute!, withForKey: strKeyChild, withValue: dictSDKInput[keyPath:strkeyPath]!, withIsParent: false, withTag: "") as [String:Any]
                    if dictForm.count > 0 {
                        if !(dictForm["faultAttribute"] as! Int != 0) {
                            arrayFltTmp.append(dictForm["dataAtt"] as! [String : Any])
                        } else {
                            arrayRptTmp.append(dictForm["dataAtt"] as! [String : Any])
                        }
                    }
                }
                
                if arrayFltTmp.count > 0 {
                    var dictPFlt: [String:Any] = [:]
                    for dicD:[String:Any] in arrayFltTmp {
                        dictPFlt[dicD["key"] as! String] = dicD["value"]
                    }
                    arrayFltAttrData.append(["key": dictSelectAttribute!["p"] as Any, "value": dictPFlt])
                }
                
                if arrayRptTmp.count > 0 {
                    var dictPRpt: [String:Any] = [:]
                    for dicD:[String:Any] in arrayRptTmp {
                        dictPRpt[dicD["key"] as! String] = dicD["value"]
                    }
                    arrayRptAttrData.append(["key": dictSelectAttribute!["p"] as Any, "value": dictPRpt])
                }
                
            } else {//Attribute has no parent
                print("Attribute is not parent")
                if dictCommonAttribute != nil {
                    let strkeyPath = KeyPath("data." + strKey)
                    let dictForm = getAttributeForm(with: dictCommonAttribute!, withForKey: strKey, withValue: dictSDKInput[keyPath:strkeyPath]!, withIsParent: true, withTag: dictDevice["tg"] as! String)
                    if dictForm.count > 0 {
                        if !(dictForm["faultAttribute"] as! Int != 0) {
                            arrayFltAttrData.append(dictForm["dataAtt"] as! [String : Any])
                        } else {
                            arrayRptAttrData.append(dictForm["dataAtt"] as! [String : Any])
                        }
                    }
                } else {
                    print("Common attribute not available")
                }
            }
            
            if arrayFltAttrData.count > 0 {
                for dicD:[String:Any] in arrayFltAttrData {
                    dictFaultAttributeData[dicD["key"] as! String] = dicD["value"]
                }
            }
            if arrayRptAttrData.count > 0 {
                for dicD:[String:Any] in arrayRptAttrData {
                    dictRptAttributeData[dicD["key"] as! String] = dicD["value"]
                }
            }
            
        }
        
        print("dictFaultAttributeData: \(dictFaultAttributeData)")
        print("dictRptAttributeData: \(dictRptAttributeData)")
        
        var dictDataFault = [String: Any]()
        if dictFaultAttributeData.count > 0 {
            dictDataFault["id"] = dictDevice["id"]
            dictDataFault["dt"] = timeInput
            dictDataFault["d"] = [dictFaultAttributeData]
            dictDataFault["tg"] = dictDevice["tg"]
        }
        var dictDataRpt = [String: Any]()
        if dictRptAttributeData.count > 0 {
            dictDataRpt["id"] = dictDevice["id"]
            dictDataRpt["dt"] = timeInput
            dictDataRpt["d"] = [dictRptAttributeData]
            dictDataRpt["tg"] = dictDevice["tg"]
        }
        
        return ["faultdata": dictDataFault, "rptdata": dictDataRpt]
    }
    /**
     getAttributeForm
     
    - parameters:
        - dictAttribute:  data in [String:Any] format
        - strKey:
        - idValue:
        - boolYNParent:
        - strTag:
      
     - Returns
        returns data in [String: Any] format
     */
    private func getAttributeForm(with dictAttribute: [String: Any], withForKey strKey: String, withValue idValue: Any, withIsParent boolYNParent: Bool, withTag strTag: String) -> [String: Any] {
        var dictResultAttribute = [String: Any]()
        for dict: [String: Any] in dictAttribute["d"] as! [[String: Any]] {
            if boolYNParent {
                if (dict["ln"] as! String == strKey) && (dict["tg"] as! String == strTag) {
                    let dictAttr = [strKey: idValue]
                    let boolYN: Bool = checkForIsValidOrNotWith(forData: dict, withValue: idValue)
                    dictResultAttribute["faultAttribute"] = (boolYN ? 1 : 0)
                    dictResultAttribute["dataAttribute"] = dictAttr
                    dictResultAttribute["dataAtt"] = ["key": strKey, "value": idValue]
                }
            } else {
                if (dict["ln"] as! String == strKey) {
                    let dictAttr = [strKey: idValue]
                    let boolYN: Bool = checkForIsValidOrNotWith(forData: dict, withValue: idValue)
                    dictResultAttribute["faultAttribute"] = (boolYN ? 1 : 0)
                    dictResultAttribute["dataAttribute"] = dictAttr
                    dictResultAttribute["dataAtt"] = ["key": strKey, "value": idValue]
                }
            }
        }
        return dictResultAttribute
    }
    private func checkForIsValidOrNotWith(forData dictForData: [String: Any], withValue idValue: Any) -> Bool {
        if dictForData["dt"] as? Int == DataType.DTNumber {
            let scan = Scanner(string: "\(Int(String(describing: idValue)) ?? 0)")
            var val: Int32 = 0
            if scan.scanInt32(&val) && scan.isAtEnd {
                
            } else {
                return false
            }
        }
        let arr = (dictForData["dv"] as! String).components(separatedBy: ",")
        if arr.count != 0 && !(dictForData["dv"] as! String == "") {
            if dictForData["dt"] as? Int == DataType.DTNumber {
                let valueToCheck = Int(String(describing: idValue)) ?? 0
                var boolInYN = false
                for strObject: String in arr {
                    if strObject.components(separatedBy: "to").count == 2 {
                        let arrayComponent = strObject.components(separatedBy: "to")

                        let min = Int(arrayComponent[0].trimmingCharacters(in: .whitespaces)) ?? 0
                        let max = Int(arrayComponent[1].trimmingCharacters(in: .whitespaces)) ?? 0

                        if valueToCheck <= max && valueToCheck >= min {
                           // print("if")
                            boolInYN = true
                        }
                    } else {
                        if Int(strObject) ?? 0 == valueToCheck || strObject.count == 0 {
                            boolInYN = true
                        }
                    }
                }
                return boolInYN
            } else if dictForData["dt"] as? Int == DataType.DTString {
                if arr.contains(idValue as! String) {
                    return true
                }
                return false
            }
        }
        return true
    }
    //MARK: - Method - Reachability Methods
    /**
        check internet available or not
            
        - Returns
                returns boll value for available or not
     */
    func checkInternetAvailable() -> Bool {
        let networkStatus = try! Reachability().connection
        
        switch networkStatus {
//        case nil:
//            return false
        case .cellular:
            return true
        case .wifi:
            return true
        case .none, .unavailable:
            return false
        }
    }
    
    /*
     observer for whenver rechability changed
     */
    func reachabilityObserver() {
        self.reachability = try! Reachability()
        NotificationCenter.default.addObserver(self, selector:#selector(self.reachabilityChanged), name: NSNotification.Name.reachabilityChanged, object: nil)
        do {
            try reachability?.startNotifier()
        } catch( _) {
        }
    }
    
    /*
     observer function will be called whenever reachability changed
     */
    @objc private func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        
        var boolInternetAvailable: Bool = false
        switch reachability.connection {
        
        case .cellular:
            boolInternetAvailable = true
            print("Network available via Cellular Data.")
            break
        case .wifi:
            boolInternetAvailable = true
            print("Network available via WiFi.")
            break
        case .none:
            print("Network is not available.")
            break
        case .unavailable:
            print("Network unavailable.")
        
        }
        var boolCanReconnectYN = false
        if boolInternetAvailable && !objMQTTClient.boolIsInternetAvailableYN {
            boolCanReconnectYN = true
        }
        objMQTTClient.boolIsInternetAvailableYN = boolInternetAvailable
        if boolCanReconnectYN {
            objMQTTClient.connectMQTTAgain()
        }
    }
    //MARK: - Method - Custom Methods
    /*
     startEdgeDeviceProcess
     
     - Parameters
        - dictSyncResponse: date as [String:Any] format
     
     - Returns
        returns nothing
     */
    private func startEdgeDeviceProcess(dictSyncResponse: [String:Any]) {
        let boolEdgeDevice = dictSyncResponse[keyPath: "meta.edge"] as? Int
        //dictSyncResponse["ee"] as! Bool
//        var dictSyncResponseTemp = dictSyncResponse
        if boolEdgeDevice == 1 {
            if let attributes = IoTConnectManager.sharedInstance.attributes{
                IoTConnectManager.sharedInstance.attributes?.connectedTime = Date()
                if let att = attributes.att{
                    for i in 0...att.count-1{
                        for j in 0...(att[i].d?.count ?? 0)-1{
                            if let d = att[i].d?[j]{
                                arrAttData.append(d)
                                var tw = d.tw ?? ""
                                let twUnit = String(tw.removeLast())
                                var timeInterval = tw.toDouble()
                                
                                if twUnit == "h"{
                                    timeInterval = (tw.toDouble() ?? 0.0) * 3600
                                }else if twUnit == "m"{
                                    timeInterval = (tw.toDouble() ?? 0.0) * 60
                                }
                                tw = String(tw.dropLast())
                                
                                let parentName = att[i].p
                                
                                if parentName?.isEmpty == true ||
                                    parentName == nil{
                                    timerEdgeDevice.append( Timer.scheduledTimer(timeInterval: timeInterval ?? 0.0, target: self, selector: #selector(fireTimerForEdgeDevice), userInfo: d, repeats: true))
                                }else{
                                    var attD = d
                                    attD.p = parentName ?? ""
                                    timerEdgeDevice.append( Timer.scheduledTimer(timeInterval: timeInterval ?? 0.0, target: self, selector: #selector(fireTimerForEdgeDevice), userInfo: attD, repeats: true))
                                    break
                                }
                                
                              
                                
//                                timerEdgeDevice =
//                                Timer.scheduledTimer(timeInterval: timeInterval ?? 0.0, target: self, selector: #selector(fireTimerForEdgeDevice), userInfo: d, repeats: true)
                            }
                        }
                    }
                }
            }
            
    
//            objCommon.setEdgeConfiguration(attributes: dictSyncResponseTemp["att"] as! [[String:Any]], uniqueId: strUniqueId, devices: dictSyncResponseTemp["d"] as! [[String:Any]]) { (res) in
//                if (res["status"] as! Bool) {
//                    dictSyncResponseTemp["edgeData"] = res[keyPath:"data.mainObj"]
//                    (res[keyPath:"data.intObj"] as! [[String:Any]]).forEach { (data) in
//                        self.objCommon.setIntervalForEdgeDevice(tumblingWindowTime: data["tumblingWindowTime"] as! String, timeType: data["lastChar"] as! String, edgeAttributeKey: data["edgeAttributeKey"] as! String, uniqueId: data["uniqueId"] as! String, attrTag: data["attrTag"] as! String, env: self.strEnv.rawValue, offlineConfig: self.dataSDKOptions.OfflineStorage, intervalObj: self.intervalObj, cpId: self.strCPId, isDebug: self.boolDebugYN)
//                    }
//                }
//            }
        }
    }
    
    @objc func fireTimerForEdgeDevice(timer:Timer){
        print("timer userInfo \(timer.userInfo ?? "")")
        if let userInfo = timer.userInfo as? AttData{
            let ln = (userInfo.p == nil ? userInfo.ln ?? "" : userInfo.p)!//userInfo.ln ?? ""

            if !arrCalcDictEdgeDevice.isEmpty{
                for i in 0...arrCalcDictEdgeDevice.count-1{
                    print("fire timer \(i)")
                    var dictD = arrCalcDictEdgeDevice[i]["d"] as? [String:Any]
                    if let valDict = dictD?[ln]{
                        print("Dict found")
                        let dataToSend = [
                            "dt":arrCalcDictEdgeDevice[i]["dt"] ?? "",
                            "d":[
                                [
                                    "id":arrCalcDictEdgeDevice[i]["id"] ?? "",
                                    "tg":arrCalcDictEdgeDevice[i]["tg"] ?? "",
                                    "dt":arrCalcDictEdgeDevice[i]["dt"] ?? "",
                                    "d":[
                                        "\(ln )":valDict
                                    ]
                                ]]] as [String : Any]
                        let topic = dictSyncResponse[keyPath:"p.topics.erpt"] as! String
                        objMQTTClient.publishTopicOnMQTT(withData: dataToSend, topic: topic)
                        dictD?.removeValue(forKey: "\(ln )")
                                               arrCalcDictEdgeDevice[i]["d"] = dictD
                                               print("arrCalcDictEdgeDevice \(arrCalcDictEdgeDevice)")
                        if let firstIndexData = arrDataEdgeDevices.firstIndex(where: {$0[ln] != nil}){
                            arrDataEdgeDevices.remove(at: firstIndexData)
                            print("arrDataEdgeDevices \(arrDataEdgeDevices)")
                        }
                        break
                    }
                }
//                var dictD = arrCalcDictEdgeDevice["d"] as? [String:Any]
//                if dictD?.isEmpty == false{
//                    if let val = dictD?[ln ?? ""]{
//                        let dataToSend = [
//                            "dt":arrCalcDictEdgeDevice["dt"] ?? "",
//                            "d":[
//                                [
//                                "id":arrCalcDictEdgeDevice["id"] ?? "",
//                                "tg":arrCalcDictEdgeDevice["tg"] ?? "",
//                                "dt":arrCalcDictEdgeDevice["dt"] ?? "",
//                                "d":[
//                                    "\(ln ?? "")":val
//                                    ]
//                            ]]] as [String : Any]
//                        let topic = dictSyncResponse[keyPath:"p.topics.erpt"] as! String
//                        objMQTTClient.publishTopicOnMQTT(withData: dataToSend, topic: topic)
//                        dictD?.removeValue(forKey: "\(ln ?? "")")
//                        arrCalcDictEdgeDevice["d"] = dictD
//                        print("arrCalcDictEdgeDevice \(arrCalcDictEdgeDevice)")
//                        if let firstIndexData = arrDataEdgeDevices.firstIndex(where: {$0[ln ?? ""] != nil}){
//                            arrDataEdgeDevices.remove(at: firstIndexData)
//                            print("arrDataEdgeDevices \(arrDataEdgeDevices)")
//                        }
//                    }
//                }
            }else{
                print("arrCalcDictEdgeDevice is empty")
            }
        }else{
            print("userinfo is not decoded")
        }
    }
}
