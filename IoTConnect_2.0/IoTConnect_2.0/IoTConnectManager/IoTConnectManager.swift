//
//  IoTConnectManager.swift
//  IoTConnect
//
//  Created by Devesh Mevada on 8/20/21.
//

import Foundation
import Network

class IoTConnectManager {
    
    /*!
     * @brief Use Shared instance to access IoTConnectManager. Singleton instance.
     */
    static let sharedInstance = IoTConnectManager()
    
    //MARK:- Variables
    var blockHandlerDeviceCallBack : GetDeviceCallBackBlock!
    var blockHandlerTwinUpdateCallBack : GetTwinUpdateCallBackBlock!
    var blockHandlerGetAttribuesCallBack : GetAttributesCallbackBlock!
    var blockHandlerGetTwinsCallBack : GetTwinCallBackBlock!
    var blockHandlerGetChildDevicesCallback : GetChildDevicesCallBackBlock!
    var strCPId: String!
    var strUniqueId: String!
    var strEnv: Environment = .PROD
    var strDiscoveryURL: String = SDKURL.discoveryHost
    var dictReference: [String:Any]!
    var dictSyncResponse: [String:Any]!
    var dataSDKOptions: SDKClientOption!
    var boolCanCallInialiseYN: Bool = true
    var boolDebugYN: Bool = false
    var timerNotRegister: Timer?
    var objCommon: Common!
    var objMQTTClient: MQTTClient!
    var DATA_FREQUENCY_NEXT_TIME: Date?
    var CERT_PATH_FLAG: Bool = true
    var reachability: Reachability?
    var intervalObj: [Any] = []
    var repeatTimerCount = 0
    var identity:Identity?
    var attributes:AttributesData?
    var df = 0
    var prevSendDataTime:Date?
    var arrAttData = [AttData]()
    var arrDataEdgeDevices = [[String:Any]]()
    var arrCalcDictEdgeDevice = [[String:Any]]()
    var timerEdgeDevice = [Timer]()
    var edgeRules:ModelEdgeRule?
    
    init() {}
    
    //MARK: - Method - SDK-Initialiase
    
    /**
     - parameters:
     - cpId: comoany ID
     - uniqueId:Device unique identifier
     - env: Device environment
     - sdkOptions:Device SDKOptions for SSL Certificates and Offline Storage
     - deviceCallback
     - twinUpdateCallback
     
     - Returns
     returns nothing
     */
    init(cpId: String, uniqueId: String, env: String, sdkOptions: SDKClientOption?, deviceCallback: @escaping GetDeviceCallBackBlock, twinUpdateCallback: @escaping GetDeviceCallBackBlock, attributeCallBack: @escaping GetAttributesCallbackBlock, twinsCallBack: @escaping GetTwinCallBackBlock,getChildCallback: @escaping GetChildDevicesCallBackBlock) {
        
        objCommon = Common(cpId, uniqueId)
        strCPId = cpId
        strUniqueId = uniqueId
        if !env.isEmpty {
            strEnv = Environment(rawValue: env)!
        }
        
        if sdkOptions != nil {
            dataSDKOptions = sdkOptions
        } else {
            dataSDKOptions = SDKClientOption()
        }
        
        boolDebugYN = dataSDKOptions.debug
        
        if dataSDKOptions.discoveryUrl != nil {
            if dataSDKOptions.discoveryUrl!.isEmpty {
                objCommon.manageDebugLog(code: Log.Errors.ERR_IN02, uniqueId: uniqueId, cpId: cpId, message: "", logFlag: false, isDebugEnabled: boolDebugYN)
            } else {
                strDiscoveryURL = dataSDKOptions.discoveryUrl!
            }
        }
        
        if dataSDKOptions.SSL.Certificate != nil {
            let dataCertificate = dataSDKOptions.SSL.Certificate
            if !objCommon.checkForIfFileExistAtPath(filePath: dataCertificate as Any) {
                CERT_PATH_FLAG = false
            }
        } else {
            CERT_PATH_FLAG = false
        }
        
        objMQTTClient = MQTTClient(cpId, uniqueId, dataSDKOptions, CERT_PATH_FLAG, boolDebugYN)
        
        objMQTTClient.boolIsInternetAvailableYN = checkInternetAvailable()
        reachabilityObserver()
        
        initialize(cpId: cpId, uniqueId: uniqueId, deviceCallback: deviceCallback, twinUpdateCallback: twinUpdateCallback, getAttributesCallback: attributeCallBack,getTwinsCallback: twinsCallBack, getChildDevucesCallback: getChildCallback)
    }
    
    //MARK:- Sample API check
    /*
     sample api call to get base urls
     
     - Returns
     returns nothing
     */
    fileprivate func sampleAPI() {
        HTTPManager().getBaseUrls { (data) in
            self.saveFile(data: data)
            self.sampleAPI2(data: data)
        } failure: { (error) in
            print(error)
        }
    }
    
    /*
     sample API call for sync call API
     
     - Returns
     returns nothing
     */
    fileprivate func sampleAPI2(data: Discovery) {
        let cpid = "nine"
        let uniqueId = "ios"
        HTTPManager().syncCall(dynamicBaseUrl: data.d.bu, cpid: cpid, uniqueId: uniqueId) { (data) in
            self.sampleMqttConnection(cpid: cpid, uniqueId: uniqueId, iotObj: data)
        } failure: { (error) in
            print(error)
        }
    }
    
    /**
     
     - Parameters:
     - cpid: Provide a company identifier
     - uniqueId:  Device unique identifier
     - iotObj:
     - Returns
     returns nothing
     
     **/
    fileprivate func sampleMqttConnection(cpid: String, uniqueId: String, iotObj: IoTData) {
        let config = CocoaMqttConfig(cpid: cpid,
                                     uniqueId: uniqueId,
                                     mqttConnectionType: .userCredntialAuthentication,
                                     certificateConfig: nil,
                                     offlineStorageConfig: nil,
                                     iotData: iotObj)
        let mqtt = MqttClientManager(mqttConfig: config)
        mqtt.connect { (status) in
            print(status ? "Mqtt Connected ✅" : "Mqtt Failed 🚫")
        }
    }
    
    /**
     save date of Discovery API response
     
     - Parameters
     -data: Discovery API response model class
     
     - Returns
     returns nothing
     */
    
    fileprivate func saveFile(data: Discovery) {
        if let data = try? JSONEncoder().encode(data) {
            let cacheData = CacheModel(fileName:"text.json", data: data)
            let cacheManager = CacheManager()
            cacheManager.saveDataToFile(data: cacheData) { (error) in
                if error == nil {
                    print("Save successfully")
                } else {
                    print("Failed to save")
                }
            }
        }
    }
    //MARK:-
    
    //MARK: - Method - SDK-Deinit
    deinit {
        print("deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Methods - SDK
    
    /**
     send data on MQTT
     
     - paramteres
     - data:data in [String:Any] format
     
     - Returns
     Returns nothing
     
     */
    func sendData(data: [String:Any]) {
        if dictSyncResponse.count > 0{
            let metaInfo = self.dictSyncResponse["meta"] as? [String:Any]
            df = metaInfo?["df"] as? Int ?? 0
            
//            if let time = prevSendDataTime{
//                let diff = Int(Date().timeIntervalSince(time))
//                print("df \(df) diff\(diff) \(time) \(Date())")
//                if diff >= df{
//                    validateData(data: data)
//                }else{
//                    print("Diff is lt")
//                }
//            }else{
//                print("prevsendData is nil")
                validateData(data: data)
//            }
           
//
//            if diff >= df{
//                validateData(data: data)
//            }else{
//                print("Diff is lt")
//            }
//            let topic = dictSyncResponse[keyPath:"p.topics.rpt"] as! String
//            objMQTTClient.publishTopicOnMQTT(withData: data, topic: topic)
        }else {
            self.objCommon.manageDebugLog(code: Log.Errors.ERR_SD06, uniqueId: strUniqueId, cpId: strCPId, message: "", logFlag: false, isDebugEnabled: boolDebugYN)
        }
        
        //        if data.count > 0 {
        //            if dictSyncResponse.count > 0 {
        //                if strUniqueId != data[0]["uniqueId"] as? String {
        //                    self.objCommon.manageDebugLog(code: Log.Errors.ERR_SD02, uniqueId: strUniqueId, cpId: strCPId, message: "", logFlag: false, isDebugEnabled: boolDebugYN)
        //                } else {
        //                    let boolEdgeDevice = dictSyncResponse["ee"] as! Bool
        //                    if boolEdgeDevice {
        //                        setSendDataFormat(data: data)
        //                    } else {
        //                        let dataFrequencyInSec = dictSyncResponse[keyPath: "sc.df"] as! Int
        //                        let currentTime = Date()
        //                        if dataFrequencyInSec == 0 || DATA_FREQUENCY_NEXT_TIME == nil || (DATA_FREQUENCY_NEXT_TIME != nil &&  DATA_FREQUENCY_NEXT_TIME! < currentTime) {
        //                            setSendDataFormat(data: data)
        //
        //                            DATA_FREQUENCY_NEXT_TIME = currentTime.addingTimeInterval(TimeInterval(dataFrequencyInSec))
        //                        } else {
        //                            print("DF: Drop Send Data")
        //                        }
        //                    }
        //                }
        //            }
        //        } else {
        //            self.objCommon.manageDebugLog(code: Log.Errors.ERR_SD06, uniqueId: strUniqueId, cpId: strCPId, message: "", logFlag: false, isDebugEnabled: boolDebugYN)
        //        }
    }
    
    func sendLog(data: [String: Any]?) {
        
    }
    
    /**
     send Ack on MQTT
     
     - paramteres
     - data:data in [String:Any] format
     
     - Returns
     Returns nothing
     
     */
    func sendAck(data: [[String:Any]], msgType: String) {
        if data.count == 0 || msgType.isEmpty {
            objCommon.manageDebugLog(code: Log.Errors.ERR_CM02, uniqueId: strUniqueId, cpId: strCPId, message: "", logFlag: false, isDebugEnabled: boolDebugYN)
        } else {
            if dictSyncResponse.count > 0 {
                let timeNow = objCommon.now()
                let dict = dictSyncResponse!
                for d: [String: Any] in data  {
                    autoreleasepool {
                        var dictAck: [String:Any] = [:]
                        dictAck["cpId"] = dict["cpId"]
                        dictAck["uniqueId"] = strUniqueId
                        dictAck["t"] = timeNow
                        dictAck["mt"] = msgType
                        dictAck["d"] = d["data"]
                        dictAck["sdk"] = ["l": SDKConstants.Language, "v": SDKConstants.Version, "e": strEnv.rawValue]
                        objMQTTClient.publishTopicOnMQTT(withData: dictAck, topic: "")
                    }
                }
                objCommon.manageDebugLog(code: Log.Info.INFO_CM10, uniqueId: strUniqueId, cpId: strCPId, message: "", logFlag: true, isDebugEnabled: boolDebugYN)
            } else {
                objCommon.manageDebugLog(code: Log.Errors.ERR_CM04, uniqueId: strUniqueId, cpId: strCPId, message: "", logFlag: false, isDebugEnabled: boolDebugYN)
            }
        }
    }
    
    func storeEdgeDeviceData(arr:[[String:Any]],dictVal:[String:Any],id:String?,tg:String?,dt:String)-> [[String:Any]]{
        let key = Array(dictVal)[0].key
        let value = Array(dictVal)[0].value
        
        var arrData = arr
        
        if arrData.count > 0{
            if let firstIndex = arrData.firstIndex(where: {$0[key] != nil}){
                print("key \(key) exist")
                if let dictValue = value as? [String:Any]{
                    var data = arrData[firstIndex][key] as? [String:Any]
                    for (valDictKey,valDictValue) in dictValue{
                        if let val = data?[valDictKey]{
                            var arrDataObj = val as? [String]
                            arrDataObj?.append(valDictValue as? String ?? "")
                            data?[valDictKey] = arrDataObj
                            print("arrData before \(arrData)")
                            arrData[firstIndex][key] = data ?? [:]
                            print("arrData \(arrData)")
                        }else{
                            data?.append(anotherDict: [
                                valDictKey:[valDictValue]])
                            print("arrData before \(arrData)")
                            arrData[firstIndex][key] = data ?? [:]
                            print("arrData \(arrData)")
                        }
                    }
                }else{
                    if let _ = Double(value as? String ?? ""){
                        var arrVal =   arrData[firstIndex][key] as? [String]
                        arrVal?.append(value as? String ?? "")
                        arrData[firstIndex][key] = arrVal
                        print("arrData \(arrData)")
                    }
                }
            }else{
                print("key \(key) not exist")
                if let dictValue = value as? [String:Any]{
                    for (valDictKey,valDictValue) in dictValue{
                        arrData.append([key:[
                            valDictKey:[valDictValue]]])
                        print("arrData \(arrData)")
                    }
                }else{
                    arrData.append([key:[value]])
                    print("arrData \(arrData)")
                }
            }
        }else{
            if let valDict = value as? [String:Any]{
                for (valDictKey,valDictValue) in valDict{
                    arrData.append([key:[
                        valDictKey:[valDictValue]]])
                    print("arrData \(arrData)")
                }
            }else{
                arrData.append([key:[value]])
                print("arrData \(arrData)")
            }
        }
        
        if !arrCalcDictEdgeDevice.isEmpty{
            if let firstIndex = arrCalcDictEdgeDevice.firstIndex(where: {$0["id"] as? String ?? "" == id}){
                var dataDevice = arrCalcDictEdgeDevice[firstIndex]
                var dictD = dataDevice["d"] as? [String:Any]
                if dictD?.isEmpty == true{
                    if let valDict = value as? [String:Any]{
                        for (valDictKey,valDictValue) in valDict{
                            dictD?.append(anotherDict: [    "\(key)":[valDictKey:["\(valDictValue)","\(valDictValue)","\(valDictValue)","\(valDictValue)","1.0","\(valDictValue)"]]])
                        }
                    }else{
                        dictD?.append(anotherDict: ["\(key)":["\(value)","\(value)","\(value)","\(value)","1.0","\(value)"]])
                    }
                    dataDevice["d"] = dictD
                    arrCalcDictEdgeDevice[firstIndex] = dataDevice
                    print("arrCalcDictEdgeDevice contains \(arrCalcDictEdgeDevice)")
                }else{
                    if let val = dictD?[key], let firstIndexData = arrData.firstIndex(where: {$0[key] != nil}){
                        if let valDict = val as? [String:Any]{
                            let arrObjData = arrData[firstIndexData][key] as? [String:Any]
                            print("key \(key) exist in arrEdgeDeviceData")
                            
                            if let dictValue = value as? [String:Any]{
                                print("\(value) \(key)")
                                for (dictValueKey,dictVal) in dictValue{
                                    var arrValues = arrObjData?[dictValueKey] as? [String]
//                                    let arrFloat = arrValues?.lazy.compactMap{
//                                        Float($0.trimmingCharacters(in: .whitespaces))
//                                    }
//                                    let sum = arrFloat?.reduce(0,+)
//                                    let avg = (sum ?? 0)/Float(arrFloat?.count ?? 1 )
                                    arrValues = calcEdgeData(arrValues: arrValues ?? [], latestVal: "\(dictVal)")
                                    if valDict[dictValueKey] is [String]{
                                        print("\(dictValueKey) exist in arrCalcEdgeDevice")
                                        var val = dictD?[key] as? [String:Any]
                                        val?[dictValueKey] = arrValues
                                        dictD?[key] = val
                                        arrCalcDictEdgeDevice[firstIndex]["d"] = dictD ?? [:]
                                    }else{
                                        print("\(dictValueKey) not exist in arrCalcEdgeDevice")
                                        
                                        var val = dictD?[key] as? [String:Any]
                                        val?.append(anotherDict: [dictValueKey:arrValues ?? []])
                                        dictD?[key] = val
                                        arrCalcDictEdgeDevice[firstIndex]["d"] = dictD ?? [:]
                                    }
                                }
                            }
                        }else{
                            let arr = arrData[firstIndexData][key] as? [String]
//                            let arrFloat = arr?.lazy.compactMap{
//                                Float($0.trimmingCharacters(in: .whitespaces))
//                            }
//                            let sum = arrFloat?.reduce(0,+) ?? 0.0
//                            let avg = (sum)/Float(arrFloat?.count ?? 1)
                            
                            dictD?[key] = calcEdgeData(arrValues: arr ?? [], latestVal: "\(value)")
                            //["\(arrFloat?.min() ?? 0)","\(arrFloat?.max() ?? 0)","\(sum)","\(avg)","\(arrFloat?.count ?? 1)","\(value)"]
                            arrCalcDictEdgeDevice[firstIndex]["d"] = dictD ?? [:]
                        }
                        print("arrCalcDictEdgeDevice contains \(arrCalcDictEdgeDevice)")
                    }else{
                        if let valDict = value as? [String:Any]{
                            for (valDictKey,valDictValue) in valDict{
                                // arrData.append([key:[
                                //                valDictKey:[valDictValue]]])
                                dictD?.append(anotherDict: [
                                    "\(key)":[valDictKey:["\(valDictValue)","\(valDictValue)","\(valDictValue)","\(valDictValue)","1.0","\(valDictValue)"]]])
                            }
                        }else{
                            dictD?.append(anotherDict: ["\(key)":["\(value)","\(value)","\(value)","\(value)","1.0","\(value)"]])
                        }
                        arrCalcDictEdgeDevice[firstIndex]["d"] = dictD ?? [:]
                        print("arrCalcDictEdgeDevice contains \(arrCalcDictEdgeDevice)")
                    }
                }
            }else{
                if let valDict = value as? [String:Any]{
                    for (valDictKey,valDictValue) in valDict{
                        arrCalcDictEdgeDevice.append(["id":id ?? "","tg":tg ?? "","dt":dt,"d":[
                            "\(key)":[valDictKey:["\(valDictValue)","\(valDictValue)","\(valDictValue)","\(valDictValue)","1.0","\(valDictValue)"]]]])
                    }
                }else{
                    arrCalcDictEdgeDevice.append(["id":id ?? "","tg":tg ?? "","dt":dt,"d":[
                        "\(key)":["\(value)","\(value)","\(value)","\(value)","1.0","\(value)"]]])
                }
                print("arrCalcDictEdgeDevice contains \(arrCalcDictEdgeDevice)")
            }

            //old
            //            if let firstIndexCalcDict = arrD?.firstIndex(where: {$0[key] != nil}), let firstIndexData = arrData.firstIndex(where: {$0[key] != nil}){
            //                let arr = arrData[firstIndexData][key] as? [String]
            //                let arrFloat = arr?.lazy.compactMap{
            //                    Float($0.trimmingCharacters(in: .whitespaces))
            //                }
            //                let sum = arrFloat?.reduce(0,+) ?? 0.0
            //                let avg = Int(sum)/(arrFloat?.count ?? 1)
            //
            //                arrD?[firstIndexCalcDict] = ["\(key)":["\(arrFloat?.min() ?? 0)","\(arrFloat?.max() ?? 0)","\(sum)","\(avg)","\(arrFloat?.count ?? 1)","\(value)"]]
            //                arrCalcDictEdgeDevice[0]["d"] = arrD
            //                print("arrCalcDictEdgeDevice contains \(arrCalcDictEdgeDevice)")
            //            }else{
            //                arrD?.append(["\(key)":["\(value)","\(value)","\(value)","\(value)","1.0","\(value)"]])
            //                arrCalcDictEdgeDevice[0]["d"] = arrD
            //                print("arrCalcDictEdgeDevice \(arrCalcDictEdgeDevice)")
            //            }
            
            //            let filterArrCalc =  arrCalcDictEdgeDevice.compactMap { $0["key"] }
            //            let filterArrData =  arrData.compactMap { $0["key"] }
            //
            //
            //            if filterArrCalc.count > 0 && filterArrData.count > 0{
            //
            //            }else{
            //                arrCalcDictEdgeDevice.append(["\(key)":["\(value)","\(value)","\(value)","\(value)","1.0","\(value)"]])
            //            }
            
            //            for i in 0...arrCalcDictEdgeDevice.count-1{
            //                for(validDataKey,_) in arrCalcDictEdgeDevice[i]{
            //                    if key == validDataKey{
            //
            //                    }else{
            //                        arrCalcDictEdgeDevice.append(["\(key)":["\(value)","\(value)","\(value)","\(value)","1.0","\(value)"]])
            //                    }
            //                }
            //            }
        }else{
            if let valDict = value as? [String:Any]{
                for (valDictKey,valDictValue) in valDict{
                    arrCalcDictEdgeDevice.append(["id":id ?? "","tg":tg ?? "","dt":dt,"d":[
                        "\(key)":[valDictKey:["\(valDictValue)","\(valDictValue)","\(valDictValue)","\(valDictValue)","1.0","\(valDictValue)"]]]])
                }
            }else{
                arrCalcDictEdgeDevice.append(["id":id ?? "","tg":tg ?? "","dt":dt,"d":[
                    "\(key)":["\(value)","\(value)","\(value)","\(value)","1.0","\(value)"]]])
            }
            print("arrCalcDictEdgeDevice contains \(arrCalcDictEdgeDevice)")
        }
        return arrData
    }
    
    func calcEdgeData(arrValues:[String],latestVal:String)-> [String]{
        let arrFloat = arrValues.lazy.compactMap{
            Float($0.trimmingCharacters(in: .whitespaces))
        }
        let sum = arrFloat.reduce(0,+)
        var sumStr = String(format: "%.4f", sum)
        sumStr = Float(sumStr)?.clean ?? "0"
//        print("sumStr \(sumStr)")
        let avg = sum/Float(arrFloat.count)
        var avgStr = String(format: "%.4f", avg)
        avgStr = Float(avgStr)?.clean ?? "0"
//        print("avgStr \(avgStr) \(Float(avgStr)?.clean ?? "0")")
        return [arrFloat.min()?.clean ?? "0",arrFloat.max()?.clean ?? "0",sumStr,avgStr,"\(arrFloat.count)",latestVal]
    }

    /**
     getAllTwins
     
        Returns
         - returns nothing
     */
    
    func getAllTwins() {
        if dictSyncResponse.count > 0 {
            objMQTTClient.getAllTwins()
        } else {
            objCommon.manageDebugLog(code: Log.Errors.ERR_TP04, uniqueId: strUniqueId, cpId: strCPId, message: "", logFlag: false, isDebugEnabled: boolDebugYN)
        }
    }
    
    /**
     Update twins
     
     - parameters:
     - key: key in String format
     - value: value as any
     
     - returns:
     Returns nothing
     */
    
    func updateTwin(key: String, value: Any) {
        if dictSyncResponse.count > 0 {
            let strV = value as? String
            
            if key.isEmpty || strV == nil || strV?.count == 0 {
                objCommon.manageDebugLog(code: Log.Errors.ERR_TP03, uniqueId: strUniqueId, cpId: strCPId, message: "", logFlag: false, isDebugEnabled: boolDebugYN)
            } else {
                objMQTTClient.publishTwinPropertyDataOnMQTT(withData: [key: value])
            }
        } else {
            objCommon.manageDebugLog(code: Log.Errors.ERR_TP02, uniqueId: strUniqueId, cpId: strCPId, message: "", logFlag: false, isDebugEnabled: boolDebugYN)
        }
    }
    
    /**
     Dispose description
     
     - parameters:
     - sdkconnection: description
     
     - returns:
     Returns nothing
     */
    
    func dispose(sdkconnection: String = "") {
        if dictSyncResponse.count > 0 {
            objMQTTClient.disconnect()
//            timerEdgeDevice?.invalidate()
//            timerEdgeDevice = nil
            if timerEdgeDevice.count > 0{
                for i in 0...timerEdgeDevice.count-1{
                    let t:Timer = timerEdgeDevice[i];
                    t.invalidate()
                }
            }
           
            timerEdgeDevice = [Timer]()
            if sdkconnection != "" {
                objCommon.deleteAllLogFile(logPath: "logs/offline/" + strCPId + "_" + strUniqueId + "/", debugYN: boolDebugYN)
            }
        } else {
            objCommon.manageDebugLog(code: Log.Info.INFO_DC01, uniqueId: strUniqueId, cpId: strCPId, message: "", logFlag: true, isDebugEnabled: boolDebugYN)
        }
    }
    
    /**
     Get attaributs

     - parameters:
     - callBack:
     
     - returns:
     Returns nothing
     */
    
    func getAttributes(callBack: @escaping GetAttributesCallbackBlock) -> () {
        if dictSyncResponse.count > 0 {
            objMQTTClient.publishTopicOnMQTT(withData:["mt":CommandType.GET_DEVICE_TEMPLATE_ATTRIBUTE], topic: "")
            self.objCommon.manageDebugLog(code: Log.Info.INFO_GA01, uniqueId: self.strUniqueId, cpId: self.strCPId, message: "", logFlag: true, isDebugEnabled: self.boolDebugYN)
//            if let hasData = dictSyncResponse["has"] as? [String:Any]{
//                if let d = hasData["d"] as? Int{
//                    if d == 1{
//                        objMQTTClient.publishTopicOnMQTT(withData:["mt":CommandType.GET_CHILD_DEVICE])
//                    }
//                }
//                if let attr = hasData["attr"] as? Int{
//                    if attr == 1{
//                        objMQTTClient.publishTopicOnMQTT(withData:["mt":CommandType.GET_DEVICE_TEMPLATE_ATTRIBUTE])
//                    }
//                }
//                if let set = hasData["set"] as? Int{
//                    if set == 1{
//                        objMQTTClient.publishTopicOnMQTT(withData:["mt":CommandType.GET_DEVICE_TEMPLATE_TWIN])
//                    }
//                }
//                if let i = hasData["r"] as? Int{
//                    if i == 1{
//                        objMQTTClient.publishTopicOnMQTT(withData:["mt":CommandType.GET_EDGE_RULE])
//                    }
//                }
//                if let ota = hasData["ota"] as? Int{
//                    if ota == 1{
//                        objMQTTClient.publishTopicOnMQTT(withData:["mt":CommandType.GET_PENDING_OTAS])
//                    }
//                }
//            }
           
//            objCommon.getAttributes(dictSyncResponse: dictSyncResponse) { (data, msg) in
//                print("data: ", data as Any)
//                var sdkDataArray: [[String:Any]] = []
//
//                (self.dictSyncResponse["d"] as! [[String:Any]]).forEach { (device) in
//                    var attArray: [String:Any] = ["device": ["id": device["id"], "tg": device["tg"] ?? nil], "attributes": []] //device.tg == "" ? undefined : device.tg
//                    let attributeData = data!["attribute"] as! [[String:Any]]
//                    attributeData.forEach { (attribData) in
//                        var attrib = attribData
//                        if (attrib["p"] as! String == "") {// Parent
//                            if (attrib["dt"] as? Int == 2) {
//                                print("attrib: ", attrib)
//                                attrib.removeValue(forKey: "agt")
//                                var pcAttributes = [
//                                    "ln" : attrib["p"],
//                                    "dt": self.objCommon.dataTypeToString(value: attrib["dt"] as! Int),
//                                    "tw": attrib["tw"] ?? nil,
//                                    "d" : []
//                                ]
//
//                                (attrib["d"] as! [[String:Any]]).forEach { (attData) in
//                                    let att = attData
//                                    if(att["tg"] as! String == device["tg"] as! String) {// Parent
//                                        let cAttribute = [
//                                            "ln": att["ln"],
//                                            "dt": self.objCommon.dataTypeToString(value: att["dt"] as! Int),
//                                            "dv": att["dv"],
//                                            "tg": att["tg"] ?? nil,
//                                            "tw": att["tw"] ?? nil
//                                        ]
//
//                                        var dA = pcAttributes["d"] as! [[String:Any]]
//                                        dA.append(cAttribute as [String : Any])
//                                        pcAttributes["d"] = dA
//                                    }
//                                }
//
//                            } else {
//                                (attrib["d"] as! [[String:Any]]).forEach { (attData) in
//                                    var att = attData
//                                    if(att["tg"] as! String == device["tg"] as! String) {// Parent
//                                        if(att["tg"] as! String == "") {
//                                            att.removeValue(forKey: "tg")
//                                        }
//                                        att.removeValue(forKey: "agt")
//                                        att["dt"] = self.objCommon.dataTypeToString(value: att["dt"] as! Int)
//                                        var attributesA = attArray["attributes"] as! [[String:Any]]
//                                        attributesA.append(att)
//                                        attArray["attributes"] = attributesA
//                                    }
//                                }
//                            }
//                        } else {
//                            if (attrib["tg"] as! String == device["tg"] as! String) {// Parent
//                                attrib.removeValue(forKey: "agt")
//                                var pcAttributes = [
//                                    "ln" : attrib["p"] ?? "",
//                                  "dt": self.objCommon.dataTypeToString(value: attrib["dt"] as! Int),
//                                  "tg": attrib["tg"] ?? "",
//                                  "tw": attrib["tw"] ?? "",
//                                  "d" : []
//                                ] as [String : Any]
//                                (attrib["d"] as! [[String:Any]]).forEach { (attData) in
//                                    let att = attData
//                                    if(att["tg"] as! String == device["tg"] as! String) {// Parent
//                                        let cAttribute = [
//                                            "ln": att["ln"],
//                                            "dt": self.objCommon.dataTypeToString(value: att["dt"] as! Int),
//                                            "dv": att["dv"],
//                                            "tg": att["tg"] ?? nil,
//                                            "tw": att["tw"] ?? nil
//                                        ]
//
//                                        var dA = pcAttributes["d"] as! [[String:Any]]
//                                        dA.append(cAttribute as [String : Any])
//                                        pcAttributes["d"] = dA
//                                    }
//                                }
//                                var pcAttributesA = attArray["attributes"] as! [[String:Any]]
//                                pcAttributesA.append(pcAttributes as [String : Any])
//                                attArray["attributes"] = pcAttributesA
//                            }
//                        }
//                    }
//                    sdkDataArray.append(attArray)
//                }
//                print("sdkDataArray: ", sdkDataArray)
//                self.objCommon.manageDebugLog(code: Log.Info.INFO_GA01, uniqueId: self.strUniqueId, cpId: self.strCPId, message: "", logFlag: true, isDebugEnabled: self.boolDebugYN)
//                callBack(true, sdkDataArray, "Attribute get successfully.")
//            }
        } else {
            objCommon.manageDebugLog(code: Log.Errors.ERR_GA02, uniqueId: strUniqueId, cpId: strCPId, message: "", logFlag: false, isDebugEnabled: boolDebugYN)
            callBack("Attributes data not found")
//            callBack(false, nil, "Attributes data not found")
        }
    }
    
    func getTwins(callBack: @escaping GetTwinCallBackBlock) -> () {
        if dictSyncResponse.count > 0 {
            objMQTTClient.publishTopicOnMQTT(withData:["mt":CommandType.GET_DEVICE_TEMPLATE_TWIN], topic: "")
        }else{
            objCommon.manageDebugLog(code: Log.Errors.ERR_GA03, uniqueId: strUniqueId, cpId: strCPId, message: "", logFlag: false, isDebugEnabled: boolDebugYN)
            callBack("Twins data not found")
        }
    }
    
    func getChildDevices(callBack: GetChildDevicesCallBackBlock) -> () {
        if dictSyncResponse.count > 0 {
            objMQTTClient.publishTopicOnMQTT(withData:["mt":CommandType.GET_CHILD_DEVICE], topic: "")
        }else{
            objCommon.manageDebugLog(code: Log.Errors.ERR_GA04, uniqueId: strUniqueId, cpId: strCPId, message: "", logFlag: false, isDebugEnabled: boolDebugYN)
            callBack("Child Devices data not found")
        }
    }
    
}










