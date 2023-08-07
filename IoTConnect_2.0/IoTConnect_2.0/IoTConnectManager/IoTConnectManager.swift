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
            
            //            for i in 0...arrData.count-1{
            //                for(validDataKey,_) in arrData[i]{
            //                    if key == validDataKey{
            //                        print("key \(key) exist \(arr[i])")
            //                        if let dictValue = value as? [String:Any]{
            //                            for (valDictKey,valDictValue) in dictValue{
            //                                if let firstIndex = arrData.firstIndex(where: {$0[key] != nil}){
            //                                    var data = arrData[firstIndex][key] as? [String:Any]
            //
            //                                    if let val = data?[valDictKey] {
            //                                        var arrDataObj = val as? [String]
            //                                        arrDataObj?.append(valDictValue as? String ?? "")
            //                                        data?[valDictKey] = arrDataObj
            //                                        print("arrData before \(arrData)")
            //                                        arrData[firstIndex][key] = data ?? [:]
            //                                        print("arrData \(arrData)")
            //                                    }else{
            //                                        data?.append(anotherDict: [
            //                                            valDictKey:[valDictValue]])
            //                                        print("arrData before \(arrData)")
            //                                        arrData[firstIndex][key] = data ?? [:]
            //                                        print("arrData \(arrData)")
            //                                    }
            //                                }
            //                            }
            //                        }else{
            //                            var arrVal =   arrData[i][validDataKey] as? [String]
            //                            arrVal?.append(value as? String ?? "")
            //                            arrData[i][validDataKey] = arrVal
            //                            print("arrData \(arrData)")
            //                        }
            //                    }else{
            //                        arrData.append([key:[value]])
            //                        print("arrData \(arrData)")
            //                    }
            //                }
            //            }
        }else{
            if let valDict = value as? [String:Any]{
                for (valDictKey,valDictValue) in valDict{
                    arrData.append([key:[
                        valDictKey:[valDictValue]]])
                    print("arrData \(arrData)")
                }
                //                for (valDictKey,valDictValue) in valDict{
                //
                //                    if let firstIndex = arrData.firstIndex(where: {$0[key] != nil}){
                //                       var data = arrData[firstIndex]
                //
                //                        if let val = data[valDictKey] {
                //                            var arrDataObj = val as? [String]
                //                            arrDataObj?.append(valDictValue as? String ?? "")
                //                            data[valDictKey] = arrDataObj
                //                            arrData[firstIndex] = data
                //                            print("arrData \(arrData)")
                //                        }else{
                //                            data.append(anotherDict: [
                //                                valDictKey:[valDictValue]])
                //                            arrData[firstIndex] = data
                //                            print("arrData \(arrData)")
                //                        }
                //                    }else{
                //                        arrData.append([key:[
                //                                        valDictKey:[valDictValue]]])
                //                        print("arrData \(arrData)")
                //                    }
                //                }
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
                            dictD?.append(anotherDict: ["\(key)":[valDictKey:["\(valDictValue)","\(valDictValue)","\(valDictValue)","\(valDictValue)","1.0","\(valDictValue)"]]])
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
                                    //["\(arrFloat?.min() ?? 0)","\(arrFloat?.max() ?? 0)","\(sum ?? 0)","\(avg)","\(arrFloat?.count ?? 0 )","\(dictVal)"]
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
        
            
//            var dictD = arrCalcDictEdgeDevice["d"] as? [String:Any]
//
//            if dictD?.isEmpty == true{
//                if let valDict = value as? [String:Any]{
//                    for (valDictKey,valDictValue) in valDict{
//                        dictD?.append(anotherDict: ["\(key)":[valDictKey:["\(valDictValue)","\(valDictValue)","\(valDictValue)","\(valDictValue)","1.0","\(valDictValue)"]]])
//                    }
//                }else{
//                    dictD?.append(anotherDict: ["\(key)":["\(value)","\(value)","\(value)","\(value)","1.0","\(value)"]])
//                }
//
//                arrCalcDictEdgeDevice["d"] = dictD
//                print("arrCalcDictEdgeDevice contains \(arrCalcDictEdgeDevice)")
//            }else{
//                if let val = dictD?[key], let firstIndexData = arrData.firstIndex(where: {$0[key] != nil}){
//                    if let valDict = val as? [String:Any]{
//                        let arrObjData = arrData[firstIndexData][key] as? [String:Any]
//                        print("key \(key) exist in arrEdgeDeviceData")
//
//                        if let dictValue = value as? [String:Any]{
//                            print("\(value) \(key)")
//                            for (dictValueKey,dictVal) in dictValue{
//
//                                var arrValues = arrObjData?[dictValueKey] as? [String]
//                                let arrFloat = arrValues?.lazy.compactMap{
//                                    Float($0.trimmingCharacters(in: .whitespaces))
//                                }
//                                let sum = arrFloat?.reduce(0,+)
//                                let avg = Int(sum ?? 0)/(arrFloat?.count ?? 1 )
//                                arrValues = ["\(arrFloat?.min() ?? 0)","\(arrFloat?.max() ?? 0)","\(sum ?? 0)","\(avg)","\(arrFloat?.count ?? 0 )","\(dictVal)"]
//
//                                if valDict[dictValueKey] is [String]{
//                                    print("\(dictValueKey) exist in arrCalcEdgeDevice")
//                                    //                                    for (valDictKey,_) in valDict{
//                                    var val = dictD?[key] as? [String:Any]
//                                    val?[dictValueKey] = arrValues
//                                    dictD?[key] = val
//                                    arrCalcDictEdgeDevice["d"] = dictD
//                                    //                                    }
//                                }else{
//                                    print("\(dictValueKey) not exist in arrCalcEdgeDevice")
//
//                                    var val = dictD?[key] as? [String:Any]
//                                    val?.append(anotherDict: [dictValueKey:arrValues ?? []])
//                                    dictD?[key] = val
//                                    arrCalcDictEdgeDevice["d"] = dictD
//                                }
//                            }
//                        }
//                    }else{
//                        let arr = arrData[firstIndexData][key] as? [String]
//                        let arrFloat = arr?.lazy.compactMap{
//                            Float($0.trimmingCharacters(in: .whitespaces))
//                        }
//                        let sum = arrFloat?.reduce(0,+) ?? 0.0
//                        let avg = Int(sum)/(arrFloat?.count ?? 1)
//
//                        dictD?[key] = ["\(arrFloat?.min() ?? 0)","\(arrFloat?.max() ?? 0)","\(sum)","\(avg)","\(arrFloat?.count ?? 1)","\(value)"]
//                        arrCalcDictEdgeDevice["d"] = dictD
//                    }
//                    print("arrCalcDictEdgeDevice contains \(arrCalcDictEdgeDevice)")
//                }else{
//                    if let valDict = value as? [String:Any]{
//                        for (valDictKey,valDictValue) in valDict{
//                            // arrData.append([key:[
//                            //                valDictKey:[valDictValue]]])
//                            dictD?.append(anotherDict: [
//                                "\(key)":[valDictKey:["\(valDictValue)","\(valDictValue)","\(valDictValue)","\(valDictValue)","1.0","\(valDictValue)"]]])
//                        }
//                    }else{
//                        dictD?.append(anotherDict: ["\(key)":["\(value)","\(value)","\(value)","\(value)","1.0","\(value)"]])
//                    }
//                    arrCalcDictEdgeDevice["d"] = dictD
//                    print("arrCalcDictEdgeDevice contains \(arrCalcDictEdgeDevice)")
//                }
//                //                dictD?.forEach({ (dictDkey,dictDVal) in
//                //                    if dictDkey == key{
//                //                        let arrVal = dictD?[dictDkey]
//                //
//                //                    }
//                //                })
//            }
//
            
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
    
//    func validateData(data: [String:Any]){
//        let arrData = data["d"] as? [[String:Any]]
//        var dictValidData = [String:Any]()
//        var dictInValidData = [String:Any]()
//        let boolEdgeDevice = dictSyncResponse[keyPath: "meta.edge"] as? Int
//        
//        if arrData?.count ?? 0 > 1{
//            print("contains child device")
//            var arrDictValidData = [[String:Any]]()
//            var arrDictInValidData = [[String:Any]]()
//            let arrAtt = IoTConnectManager.sharedInstance.attributes
//            print("att \(String(describing: arrAtt?.att?.count))")
//            
//            for i in 0...(arrData?.count ?? 0)-1{
//                if let dictValD = arrData?[i]["d"] as? [String:Any]{
//                    dictValD.forEach({ (dictkey:String,val:Any) in
//                        print("key_val gateway \(dictkey) \(val) i\(i)")
//                        
//                        for j in 0...(arrAtt?.att?.count ?? 0)-1{
////                            var isDataFound = false
//                            if let valDict = val as? [String:Any]{
//                                for (valDictKey,dictValue) in valDict{
//                                    print("valDictKey \(valDictKey) dictValue \(dictValue)")
////                                    isDataFound = false
//                                    var arrFilterD = arrAtt?.att?[j].d?.filter({$0.ln == valDictKey})
//                                    if arrFilterD?.count ?? 0 > 0{
//                                        print("arrFilterD gateway \(String(describing: arrFilterD))")
////                                        var dict = [String:Any]()
//                                        let isValidData = checkisValValid(val: dictValue as! String, dt: arrFilterD?[0].dt ?? 0, dv: arrFilterD?[0].dv)
//                                        if isValidData{
////                                            dict = dictValidData
//
//                                            if boolEdgeDevice == 1, let _ = Double(dictValue as? String ?? ""){
//                                                arrDataEdgeDevices = storeEdgeDeviceData(arr: arrDataEdgeDevices, dictVal: [dictkey:[valDictKey:dictValue]],id: arrData?[0]["id"] as? String ?? "",tg: arrData?[0]["tg"] as? String ?? "",dt: arrData?[0]["dt"] as? String ?? "" )
////                                                arrDataEdgeDevices = storeEdgeDeviceData(arr: arrDataEdgeDevices, dictVal: [valDictKey:dictValue],id: "",tg: arrFilterD?[0].tg,dt: arrData?[0]["dt"] as? String ?? "")
//                                            }
//                                            if arrDictValidData.count == 0{
//                                                arrDictValidData.append(["dt":arrData?[i]["dt"] ?? "","id":arrData?[i]["id"] ?? "","tg":arrData?[i]["tg"] ?? "","d":[dictkey:[valDictKey:dictValue]]]
//                                                )
//                                                
//                                            }else{
////                                                let filterExistData = arrDictValidData.filter({$0["id"] as? String == arrData?[i]["id"] as! String})
//                                                
//                                                if let index = arrDictValidData.firstIndex(where: {$0["id"] as? String  == arrData?[i]["id"] as? String}) {
//                                                    var dVal = arrDictValidData[index]["d"] as? [String:Any]
//                                                    let attDict = dVal?[dictkey] as? [String:Any]
//                                                    print("attDict \(String(describing: attDict))")
//                                                    let newDict = [valDictKey:dictValue]
//                                                    if attDict == nil{
//                                                        dVal?.append(anotherDict: [dictkey:[valDictKey:dictValue]])
//                                                    }else{
//                                                        dVal?[dictkey] = attDict?.merging(newDict , uniquingKeysWith: { current, _ in
//                                                            return current
//                                                        })
//                                                    }
//                                                    arrDictValidData[index]["d"]  = dVal
//                                                    print("arrDictValidData \(arrDictValidData)")
//                                                }else{
//                                                    arrDictValidData.append(["dt":arrData?[i]["dt"] ?? "","id":arrData?[i]["id"] ?? "","tg":arrData?[i]["tg"] ?? "","d":[dictkey:[valDictKey:dictValue]]]             
//                                                    )
//                                                    print("arrDictValidData \(arrDictValidData)")
//                                                }
//                                            }
//                                        }else{
////                                            dict = dictInValidData
//                                            if arrDictInValidData.count == 0{
//                                                arrDictInValidData.append(["dt":arrData?[i]["dt"] ?? "","id":arrData?[i]["id"] ?? "","tg":arrData?[i]["tg"] ?? "","d":[dictkey:[valDictKey:dictValue]]]
//                                                                          
//                                                )
//                                                print("arrDictInValidData \(arrDictInValidData)")
//                                            }else{
//                                                if let index = arrDictInValidData.firstIndex(where: {$0["id"] as? String  == arrData?[i]["id"] as? String}) {
//                                                    var dVal = arrDictInValidData[index]["d"] as? [String:Any]
//                                                    let attDict = dVal?[dictkey] as? [String:Any]
////                                                    print("attDict \(String(describing: attDict))")
//                                                    let newDict = [valDictKey:dictValue]
//                                                    if attDict == nil{
//                                                        dVal?.append(anotherDict: [dictkey:[valDictKey:dictValue]])
//                                                    }else{
//                                                        dVal?[dictkey] = attDict?.merging(newDict , uniquingKeysWith: { current, _ in
//                                                            return current
//                                                        })
//                                                    }
//                                                   
//                                                    arrDictInValidData[index]["d"]  = dVal
//                                                    print("arrDictInValidData \(arrDictInValidData)")
//                                                    
//                                                }else{
//                                                    arrDictInValidData.append(["dt":arrData?[i]["dt"] ?? "","id":arrData?[i]["id"] ?? "","tg":arrData?[i]["tg"] ?? "","d":[dictkey:[valDictKey:dictValue]]]
//                                                    )
//                                                    print("arrDictInValidData \(arrDictInValidData)")
//                                                }
//                                            }
//                                        }
//                                        arrFilterD?.removeAll()
//                                    }
//                                }
//                            }else{
//                                let arrFilterD = arrAtt?.att?[j].d?.filter({$0.ln == dictkey})
//                                if arrFilterD?.count ?? 0 > 0{
//    //                                print("arrFilterD \(arrFilterD)")
////                                    isDataFound = true
//                                    let isValidData = checkisValValid(val: val as! String, dt: arrFilterD?[0].dt ?? 0, dv: arrFilterD?[0].dv)
//                                  
//                                    if isValidData{
////                                        dictValidData.append(anotherDict: [dictkey:val])
//                                        
//                                        if boolEdgeDevice == 1, let _ = Double(val as? String ?? ""){
//                                            arrDataEdgeDevices = storeEdgeDeviceData(arr: arrDataEdgeDevices, dictVal: [dictkey:val],id: arrData?[i]["id"] as? String,tg: arrData?[i]["tg"] as? String,dt: arrData?[0]["dt"] as? String ?? "")
//                                        }
//                                        if let index = arrDictValidData.firstIndex(where: {$0["tg"] as? String  == arrData?[i]["tg"] as? String}) {
//                                            var dVal = arrDictValidData[index]["d"] as? [String:Any]
//                                            let newDict = [dictkey:val]
//                                            dVal = dVal?.merging(newDict , uniquingKeysWith: { current, _ in
//                                                return current
//                                            })
//                                            arrDictValidData[index]["d"]  = dVal
//                                        }else{
//                                            arrDictValidData.append(["dt":arrData?[i]["dt"] ?? "","id":arrData?[i]["id"] ?? "","tg":arrData?[i]["tg"] ?? "","d":[dictkey:val]]
//                                                                    
//                                            )
//                                        }
//                                        print("arrDictValidData gateway \(arrDictValidData)")
//                                    }else{
////                                        dictInValidData.append(anotherDict: [dictkey:val])
////                                        print("dictInValidData gateway \(dictInValidData)")
//                                        if let index = arrDictInValidData.firstIndex(where: {$0["tg"] as? String  == arrData?[i]["tg"] as? String}) {
//                                            var dVal = arrDictInValidData[index]["d"] as? [String:Any]
////
//                                            let newDict = [dictkey:val]
//                                            dVal = dVal?.merging(newDict , uniquingKeysWith: { current, _ in
//                                                return current
//                                            })
//                                            arrDictInValidData[index]["d"]  = dVal
//                                        }else{
//                                            arrDictInValidData.append(["dt":arrData?[i]["dt"] ?? "","id":arrData?[i]["id"] ?? "","tg":arrData?[i]["tg"] ?? "","d":[dictkey:val]])
//                                        }
//                                        print("arrDictInValidData gateway \(arrDictInValidData)")
//                                    }
//                                    break
//                                }
//                            }
//                        }
//                    })
//                }
//            }
//            
//            if !arrDictValidData.isEmpty{
//                dictValidData = ["dt":data["dt"] ?? "","d":arrDictValidData]
//
//                if boolEdgeDevice == 1{
//                
//                }else{
//                    let topic = dictSyncResponse[keyPath:"p.topics.rpt"] as! String
//                    prevSendDataTime = Date()
//                    objMQTTClient.publishTopicOnMQTT(withData: dictValidData, topic: topic)
//                }
//               
//                print("final dictValidData gateway \(dictValidData)")
//            }
//            
//            if !arrDictInValidData.isEmpty{
//                dictInValidData = ["dt":data["dt"] ?? "","d":arrDictInValidData]
//                
//                if boolEdgeDevice == 1{
//                    
//                }else{
//                    let topic = dictSyncResponse[keyPath:"p.topics.flt"] as! String
//                    prevSendDataTime = Date()
//                    objMQTTClient.publishTopicOnMQTT(withData: dictInValidData, topic: topic)
//                    print("final dictInValidData gateway \(dictInValidData)")
//                }
//            }
//        }else{
//            print("count is 1")
//            let dictValD = arrData?[0]["d"] as? [String:Any]
//
//            dictValD?.forEach {
//                print("key_val \($0.key) \($0.value)")
//                let dictValDKey = $0.key
//                let value = $0.value
////                print("attributes \(key) \(String(describing: self.attributes)) \(IoTConnectManager.sharedInstance.attributes)")
//                
//                let arrAtt = IoTConnectManager.sharedInstance.attributes
//                print("att \(String(describing: arrAtt?.att?.count))")
//                 
//                for i in 0...(arrAtt?.att?.count ?? 0)-1{
//                    print("arrAtt?.att \(i)")
////                    var isDataFound = false
////                    for j in 0...(arrAtt?.att?[i].d?.count ?? 0)-1{
////                        print("arrAtt?.att?[i].d \(j) \(key) \(String(describing: arrAtt?.att?[i].d))")
//                        if let valDict = value as? [String:Any]{
//                            for (valDictKey,dictValue) in valDict{
////                                isDataFound = false
//                                var arrFilterD = arrAtt?.att?[i].d?.filter({$0.ln == valDictKey})
//                                if arrFilterD?.count ?? 0 > 0{
//                                    print("arrFilterD \(String(describing: arrFilterD))")
//                                    var dict = [String:Any]()
////                                    isDataFound = true
////
//                                    let isValidData = checkisValValid(val: dictValue as! String, dt: arrFilterD?[0].dt ?? 0, dv: arrFilterD?[0].dv)
//                                    if isValidData{
//                                        dict = dictValidData
//                                    }else{
//                                        dict = dictInValidData
//                                    }
//                                    
//                                    if dict[$0.key] != nil{
//                                        let val = dict[$0.key] as? [String:Any]
//                                        let newVal = [valDictKey:dictValue] as? [String:Any]
//                                        dict[$0.key] = val?.merging(newVal ?? [:], uniquingKeysWith: { current, _ in
//                                            return current
//                                        })
//                                        print("dictValidData \(valDictKey) \(dictValidData)")
//                                    }else{
//                                        dict.updateValue([valDictKey:dictValue], forKey:$0.key)
//                                    }
//                                    arrFilterD?.removeAll()
//                                    if isValidData{
//                                       dictValidData = dict
//
//                                        if boolEdgeDevice == 1, let _ = Double(dictValue as? String ?? ""){
//                                            arrDataEdgeDevices = storeEdgeDeviceData(arr: arrDataEdgeDevices, dictVal: [dictValDKey:[valDictKey:dictValue]],id: arrData?[0]["id"] as? String ?? "",tg: arrData?[0]["tg"] as? String ?? "",dt: arrData?[0]["dt"] as? String ?? "" )
//                                        }
//                                    }else{
//                                        dictInValidData = dict
//                                    }
//                                    print("dictValidData \(valDictKey) \(dictValidData)")
//                                    print("dictInValidData \(valDictKey) \(dictInValidData)")
////                                    break
//                                }
////                                if isDataFound {
////                                    break
////                                }
//                            }
//                        }else{
//                            let arrFilterD = arrAtt?.att?[i].d?.filter({$0.ln == dictValDKey})
//                            if arrFilterD?.count ?? 0 > 0{
////                                print("arrFilterD \(arrFilterD)")
////                                isDataFound = true
//                                let isValidData = checkisValValid(val: value as! String, dt: arrFilterD?[0].dt ?? 0, dv: arrFilterD?[0].dv)
//                                if isValidData{
//                                    dictValidData.append(anotherDict: [$0.key:$0.value])
//                                    print("dictValidData \(dictValidData)")
//
//                                    if boolEdgeDevice == 1, let _ = Double(value as? String ?? ""){
//                                        arrDataEdgeDevices = storeEdgeDeviceData(arr: arrDataEdgeDevices, dictVal: [dictValDKey:value],id: arrData?[0]["id"] as? String ?? "",tg: arrData?[0]["tg"] as? String ?? "",dt: arrData?[0]["dt"] as? String ?? "")
//                                        
//                                        // var arrFilterD = arrAtt?.att?[i].d?.filter({$0.ln == key})
////                                        if arrValidData.count > 0{
////                                            for i in 0...arrValidData.count-1{
////                                                for(validDataKey,validDataValue) in arrValidData[i]{
////                                                    if key == validDataKey{
////                                                        print("key \(key) exist \(arrValidData[i])")
////                                                        var arrVal =   arrValidData[i][validDataKey] as? [String]
////                                                        arrVal?.append(value as? String ?? "")
////                                                        print("arrValidData \(arrValidData[i])")
////                                                    }else{
////                                                        arrValidData.append([key:[value]])
////                                                        print("arrValidData \(arrValidData)")
////                                                    }
////                                                }
////                                            }
////                                        }else{
////                                            arrValidData.append([key:[value]])
////                                        }
////                                        let diff = Int(Date().timeIntervalSince(arrAtt?.connectedTime ?? Date()))
////
////                                        if diff >= Int(arrFilterD?[0].tw ?? "") ?? 0{
////
////                                        }
//                                        
//                                    }
//                                }else{
//                                    dictInValidData.append(anotherDict: [$0.key:$0.value])
//                                    print("dictInValidData \(dictInValidData)")
//                                }
//                                break
//                            }
//                        }
////                    }
////                    if isDataFound {
////                        break
////                    }
//                }
//
//               
//                
////                if let strVal = value as? String{
////                    if let intVal = Int(strVal){
////                        print("intVal \($0.value)")
////                    }else{
////                        print("strVal \($0.value)")
////                    }
////                }else if let dictVal = value as? [String:Any]{
////                    print("dictVal \($0.value)")
////                    dictVal.forEach {_ in
////
////                    }
////                }else{
////                    print("val \($0.key) \($0.value)")
////                }
//            }
//            
//            if !dictValidData.isEmpty{
////                if boolEdgeDevice == 1{
////                    for (key,val) in dictValidData{
////                        if let valDict = val as? [String:Any]{
////                            print("val is Dict")
////                        }else
////                        {
////                            for i in 0...arrDataEdgeDevices.count-1{
////                                for(validDataKey,_) in arrDataEdgeDevices[i]{
////                                    if key == validDataKey{
////
////
////                                    }
////
////                                }
////                            }
////                        }
////                    }
////                }
//            
//             
// 
//                if boolEdgeDevice != 1{
//                    dictValidData = ["dt":data["dt"] ?? "","d":[["dt":arrData?[0]["dt"] ?? "","id":arrData?[0]["id"] ?? "","tg":arrData?[0]["tg"] ?? "","d":dictValidData]]]
//                    prevSendDataTime = Date()
//                    let topic = dictSyncResponse[keyPath:"p.topics.rpt"] as! String
//                    objMQTTClient.publishTopicOnMQTT(withData: dictValidData, topic: topic)
//                }else{
//                    print("dictValidData edgeDevice \(dictValidData)")
//                    if let ruleData = edgeRules{
//                        if let rule = ruleData.d?.r?[0].con{
//                            var arrRules = rule.components(separatedBy: "AMD")
//                            
//                            if arrRules.count > 0{
//                                for i in 0...arrRules.count-1{
//                                    let rule = arrRules[i].components(separatedBy: " ")
//                                    print("Rule seperated \(rule)")
//                                    let att = rule[0].components(separatedBy: ".")
//                                    if att.count == 1{
//                                        if let val  = dictValidData[att[0]]{
//                                           
//                                        }
//                                    }else{
//                                        
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    
//                }
//            }
//            
//            if !dictInValidData.isEmpty{
//                dictInValidData = ["dt":data["dt"] ?? "","d":[["dt":arrData?[0]["dt"],"id":arrData?[0]["id"],"tg":arrData?[0]["tg"],"d":dictInValidData]]]
//                
//                if boolEdgeDevice != 1{
//                    prevSendDataTime = Date()
//                    let topic = dictSyncResponse[keyPath:"p.topics.flt"] as! String
//                    objMQTTClient.publishTopicOnMQTT(withData: dictInValidData, topic: topic)
//                }
//            }
//        }
//        
//        func checkisValValid(val:String,dt:Int,dv:String?)-> Bool{
//            switch dt{
//            case SupportedDataType.intValue:
//                if Int32(val) != nil{
//                    if validateNumber(value: val, dv: dv, dataType: SupportedDataType.intValue) == true{
//                        return true
//                    }else{
//                        return false
//                    }
//                }else{
//                    if val.isEmpty && (dv == nil || dv?.isEmpty == true){
//                        return true
//                    }
//                    if !val.isEmpty{
//                        if let doubleVal = Double(val){
//                            let roundVal = Int32(round(doubleVal))
//                            if validateNumber(value: "\(roundVal)", dv: dv, dataType: SupportedDataType.intValue) == true{
//                                return true
//                            }else{
//                                return false
//                            }
//                        }
//                    }
//                    return false
//                }
//                
//            case SupportedDataType.boolValue:
//                let isValid = self.validateBoolValue(value: val, dv: dv)
//                if isValid{
//                    return true
//                }else{
//                    return false
//                }
//            case SupportedDataType.strVal:
//                //remaining
//                let isValid = self.validateNumber(value: val, dv: dv, dataType: SupportedDataType.decimalVal)
//                if isValid{
//                    return true
//                }else{
//                    return false
//                }
//            case SupportedDataType.bitValue:
//                let isValid = self.validateBit(value: val, dv: dv)
//                
//                if isValid{
//                    return true
//                }else{
//                    return false
//                }
//                
//            case SupportedDataType.dateValue:
//                let isValid = validateDate(value: val, dateFormat: "YYYY-MM-dd", dv: dv)
//                
//                if (isValid){
//                    return true
//                }else{
//                    return false
//                }
//                
//            case SupportedDataType.dateTimeVal:
//                let isValid = validateDate(value: val, dateFormat:"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'" , dv: dv)//"YYYY-MM-ddTHH:MM:SS.SSSZ"
//                //"yyyy-MM-dd'T'HH:mm:ssZ"
//                //yyyy-MM-dd'T'HH:mm:ss.SSS'Z'
//                
//                if isValid{
//                    return true
//                }else{
//                    return false
//                }
//                
//            case SupportedDataType.decimalVal:
//                if let floatVal = Float(val){
//                    //range is -7.9*1028
//                    if floatVal.isLessThanOrEqualTo(8121.2) &&
//                        floatVal >= -8121.2
//                    {
//                        if validateNumber(value: val, dv: dv, dataType: SupportedDataType.decimalVal) == true{
//                            return true
//                        }else{
//                            return false
//                        }
//                    }else{
//                        return false
//                    }
//                }
//                if val.isEmpty && (dv == nil || dv?.isEmpty == true){
//                    return true
//                }
//                return false
//                
//            case SupportedDataType.latLongVal:
//                //[10,8] [11,8]
//                if validateLatLong(value: val,dv: dv){
//                    return true
//                }
//                
//                return false
//                
//            case SupportedDataType.longVal:
//                if Int64(val) != nil{
//                    if validateNumber(value: val, dv: dv, dataType: SupportedDataType.longVal) == true{
//                        return true
//                    }else{
//                        return false
//                    }
//                }else{
//                    if val.isEmpty && (dv == nil || dv?.isEmpty == true){
//                        return true
//                    }
//                    if !val.isEmpty{
//                        if let doubleVal = Double(val){
//                            let roundVal = Int64(round(doubleVal))
//                            if validateNumber(value: "\(roundVal)", dv: dv, dataType: SupportedDataType.intValue) == true{
//                                return true
//                            }else{
//                                return false
//                            }
//                        }
//                    }
//                    return false
//                }
//                
//            case SupportedDataType.timeVal:
//                if dv == nil || dv?.isEmpty == true{
//                    if val.isEmpty == true{
//                        return true
//                    }
//                }
//                let arrVal = val.components(separatedBy: ":")
//                if arrVal.count >= 3{
//                    let isValid = validateDate(value: val, dateFormat: "HH:mm:ss", dv: dv)
//                    
//                    if isValid{
//                        return true
//                    }else{
//                        return false
//                    }
//                }else
//                {
//                    return false
//                }
//                
//            default:
//                return false
//            }
//        }
//    }
    
//    func validateDate(value:String,dateFormat:String,dv:String?)->Bool{
//        if value.isEmpty == true && (dv == nil || dv?.isEmpty == true){
//            return true
//        }
//        if let validDate = isDateValid(dateVal: value, dateFormat: dateFormat){
//            if dv == nil || dv?.isEmpty == true{
////                if value.isEmpty == true{
////                    return true
////                }
////                if isDateValid(dateVal: value, dateFormat: dateFormat) != nil{
//                    return true
////                }else{
////                    return false
////                }
//            }else{
//                var newDateArr = dv?.components(separatedBy: ",")
//                let arrToData = newDateArr?.filter({$0.contains("to")})
//                newDateArr?.removeAll(where: {$0.contains("to")})
//
//                if newDateArr?.contains(value) == true{
//                    return true
//                }
//
//                if arrToData?.count  ?? 0 > 0{
//                    for i in 0...(arrToData?.count ?? 0)-1{
//                        let toArr = arrToData?[i].components(separatedBy: "to")
//                        //                    let range = (Int(toArr?[0].trimmingCharacters(in:.whitespaces) ?? "") ?? 0)...(Int(toArr?[1].trimmingCharacters(in: .whitespaces) ?? "") ?? 0)
//
//                        if let startDate = isDateValid(dateVal: toArr?[0].trimmingCharacters(in: .whitespaces) ?? "", dateFormat: dateFormat),let  endDate =  isDateValid(dateVal: toArr?[1].trimmingCharacters(in: .whitespaces) ?? "", dateFormat: dateFormat){
//                            let dateRange = startDate...endDate
//                            if dateRange.contains(validDate)
//                            {
//                                return true
//                            }
//                        }
//                    }
//                }
//            }
//        }
//
////            if newDateArr?.count ?? 0 > 0{
////                if newDateArr?.contains(value) == true{
////                    return true
////                }
//////                else{
//////                    return false
//////                }
////            }
//
//
////            let newDateRange = dv?.components(separatedBy: "to")
//
////            if newDateRange?.count ?? 0 > 1{
////                if let validDate = isDateValid(dateVal: value, dateFormat: dateFormat){
////                    if let startDate = isDateValid(dateVal: newDateRange?[0] ?? "", dateFormat: dateFormat),let  endDate =  isDateValid(dateVal: newDateRange?[1] ?? "", dateFormat: dateFormat){
////                        let dateRange = startDate...endDate
////                        if dateRange.contains(validDate)
////                        {
////                            return true
////                        }
//////                        else{
//////                            return false
//////                        }
////                    }else{
////                        return false
////                    }
////                }else{
////                    return false
////                }
////            }
//
////            if dv == value{
////                return true
////            }
////        }
////
//        return false
//    }
//
//    func isDateValid(dateVal:String,dateFormat:String)->Date?{
//        let dateFormatter = DateFormatter()
////        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
//        dateFormatter.dateFormat = dateFormat
//        if let date = dateFormatter.date(from:dateVal){
//            return date
//        }else{
//            return nil
//        }
//    }
//
//    func validateBit(value:String,dv:String?)->Bool{
//        if (dv == nil || (dv?.isEmpty) == true) {
//            if value.isEmpty == true{
//                return true
//            }
//            if (value == "0" || value == "1"){
//                return true
//            }else{
//                return false
//            }
//        }else{
//            if (value == dv){
//                return true
//            }else{
//                return false
//            }
//        }
//
////        else{
////            let newDV = dv?.components(separatedBy: ",")
////
////            if newDV?.count ?? 0 > 0{
////                if newDV?.contains(value) == true{
////                    return true
////                }else{
////                    return false
////                }
////            }
////            if (value == dv){
////                return true
////            }
////        }
//
////        if (value != "0" && value != "1"){
////            return false
////        }
//
////        return false
//    }
//
//    func validateBoolValue(value:String,dv:String?)->Bool{
//        if dv != nil && dv?.isEmpty == false{
////            let newDV = dv?.components(separatedBy: ",")
////            if newDV?.count ?? 0 > 0{
////                if newDV?.contains(value) == true{
////                    return true
////                }else{
////                    return false
////                }
////            }else{
//                if value == dv{
//                    return true
//                }else{
//                    return false
//                }
////            }
//        }
//            if value == "True" ||
//                value == "False" ||
//                value == "true" ||
//                value == "false"{
//                return true
//            }
//
//        if dv == nil || dv?.isEmpty == true{
//            if value.isEmpty == true{
//                return true
//            }
//        }
//
//        return false
//    }
//
//    func validateNumber(value:String,dv:String?,dataType:Int)->Bool{
//        if dv == nil || dv?.isEmpty == true{
////            if value.isEmpty{
//                return true
////            }
//        }else{
//            var dvInComma = dv?.components(separatedBy: ",")
//            let arrToData = dvInComma?.filter({$0.contains("to")})
//            dvInComma?.removeAll(where: {$0.contains("to")})
//
//            if dvInComma?.contains(value) == true{
//                return true
//            }
//
//            if arrToData?.count ?? 0 > 0{
//                for i in 0...(arrToData?.count ?? 0)-1{
//                    let toArr = arrToData?[i].components(separatedBy: "to")
//                    if dataType == SupportedDataType.decimalVal{
//                        var arrFloat = [Float]()
//                        for item in toArr! {
//                            arrFloat.append((item.trimmingCharacters(in: .whitespaces) as NSString).floatValue)
//                        }
//
//                        if let val = Float(value){
//                            if checkValInRange(arrRange: arrFloat, value: val) == true{
//                                return true
//                            }
//                        }
//
//
//                        if dv == value{
//                            return true
//                        }
//
//                        return false
////                        if checkFloatValInRange(arrRange: toArr!, value: value) == true{
////                            return true
////                        }
//                    }else if dataType == SupportedDataType.intValue{
//                        let arrInt32 = toArr?.compactMap { Int32($0.trimmingCharacters(in: .whitespaces)) }
//
//                        if let val = Int32(value){
//                            if checkValInRange(arrRange: arrInt32 ?? [], value: val) == true{
//                                return true
//                            }
//                        }
//
//                        if dv == value{
//                            return true
//                        }
//
//                        return false
//                    }else if dataType == SupportedDataType.longVal{
//                        let arrInt64 = toArr?.compactMap { Int64($0.trimmingCharacters(in: .whitespaces)) }
//
//                        if let val = Int64(value){
//                            if checkValInRange(arrRange: arrInt64 ?? [], value: val) == true{
//                                return true
//                            }
//                        }
//
//                        if dv == value{
//                            return true
//                        }
//
//                        return false
//                    }
//                }
//            }
//
//
//
////            let dvTo = dv?.components(separatedBy: "to")
//
////            if dvTo?.count ?? 0 > 0{
////                if checkValInRange(arrRange: dvTo!, value: value) == true{
////                    return true
////                }
//////                if let firstVal = Float(dvInComma?[0] ?? ""),let seccondVal = Float(dvInComma?[1] ?? ""){
//////                    let range = firstVal...seccondVal
//////                    if range.contains(Float(value) ?? 0.0){
//////                        return true
//////                    }
//////                }
////            }
//
////            if dv == value{
////                return true
////            }
//
//
//        }
//        return false
//    }
//
//    func validateLatLong(value:String,dv:String?)->Bool{
//        if dv == nil || dv?.isEmpty == true{
//            if value.isEmpty{
//                return true
//            }
//        }
//        let regex = NSRegularExpression("\\[\\d*\\.?\\d*\\,\\d*\\.?\\d*\\]")
//        return regex.matches(value)
//    }
//
//    func checkValInRange<T:Comparable>(arrRange:[T],value:T)->Bool{
//        if arrRange.count > 0{
//            let range = arrRange[0]...arrRange[1]
//            if range.contains(value){
//                return true
//            }
//        }
//        return false
//    }
    
//    func checkFloatValInRange(arrRange:[String],value:String)->Bool{
//        if let firstVal = Float(arrRange[0].trimmingCharacters(in: .whitespaces) ),let seccondVal = Float(arrRange[1].trimmingCharacters(in: .whitespaces) ){
//            let range = firstVal...seccondVal
//            if range.contains(Float(value) ?? 0.0){
//                return true
//            }
//        }
//        return false
//    }
//
//    func checkInt32ValInRange(arrRange:[String],value:String)->Bool{
//        if let firstVal = Int32(arrRange[0].trimmingCharacters(in: .whitespaces) ),let seccondVal = Int32(arrRange[1].trimmingCharacters(in: .whitespaces) ){
//            let range = firstVal...seccondVal
//            if range.contains(Int32(value) ?? 0){
//                return true
//            }
//        }
//        return false
//    }
//
//    func checkLongValInRange(arrRange:[String],value:String)->Bool{
//        if let firstVal = Int64(arrRange[0].trimmingCharacters(in: .whitespaces) ),let seccondVal = Int64(arrRange[1].trimmingCharacters(in: .whitespaces) ){
//            let range = firstVal...seccondVal
//            if range.contains(Int64(value) ?? 0){
//                return true
//            }
//        }
//        return false
//    }
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










