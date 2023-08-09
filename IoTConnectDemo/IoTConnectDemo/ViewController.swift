//
//  ViewController.swift
//  DemoIOTConnectSDK_Swift
//
//  Created by rushabh.patel on 10/08/21.
//

import UIKit
import IoTConnect_2_0

public enum DeviceConnectionStatus{
    case connected
    case disconnected
}


class ViewController: UIViewController {
    
    //MARK: @IBOutlet
    @IBOutlet var btnStatus : UIButton!
    @IBOutlet var btnConnect : UIButton!
    @IBOutlet var txtCPID,txtUniqueID : UITextField!
    @IBOutlet var tblProperty : UITableView!
    @IBOutlet var txtView : UITextView!
    @IBOutlet weak var btnAvnet: UIButton!
    @IBOutlet weak var btnPOC: UIButton!
    @IBOutlet weak var btnQA: UIButton!
    @IBOutlet weak var btnDev: UIButton!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var viewLoader: UIView!
    @IBOutlet weak var tblViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblTag: UILabel!
    @IBOutlet weak var viewLblTag: UIView!
    @IBOutlet weak var btnSendData: UIButton!
    @IBOutlet weak var btnGetTwins: UIButton!
    @IBOutlet weak var btnChildDevicesOperation: UIButton!
    
//MARK: Variable
    private var btnConnectTitle = "CONNECT"
    private var btnDisConnectTitle = "DISCONNECT"
    private let tblViewRowheight = 44.0
    private var noOfSecrions = 0
    var env:Environment = .QA
    var devivceStatus:DeviceConnectionStatus = .disconnected
    let radioController: RadioButtonController = RadioButtonController()
    var noOfAttributes = 0
    var arAttributes = [String]()
    var dictAttributes:[String:Any]?
    var attributeData:AttributesData?
    private var arrChildDevicesAttributes:[[String:Any]]?
    private var isGetDevicesCalled = false
    private var arrChildAttributeData = [[String:[[AttData]]]]()
    private var arrParentData = [[String:[[AttData]]]]()
    private var arrSimpleDeviceData = [[String:[[AttData]]]]()
    private var is201Received:Bool = false
    private var is204Received:Bool = false
    private var identity:Identity?
    private var isDeviceGateway = false
    private var isDeviceEdge = false
    private var is204WillCalled = false
    
//MARK: view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        radioController.buttonsArray = [btnAvnet,btnQA,btnDev,btnPOC]
        radioController.defaultButton = btnQA
        
        //button Status Corner Radius
        btnStatus.layer.cornerRadius = 12.5
        
        //Register Table Header View
        let nib = UINib(nibName: "TableHeaderView", bundle: nil)
        tblProperty.register(nib, forHeaderFooterViewReuseIdentifier: "TableHeaderView")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Add Underline textfield
        self.txtCPID.addUnderLine()
        self.txtUniqueID.addUnderLine()
        
        txtView.layer.cornerRadius = 10
        txtView.layer.borderWidth = 1
        txtView.layer.borderColor = UIColor.darkGray.cgColor
    }

    //MARK: - Custom Methods
    func connectSDK() {
        
        //This code works for certificate authentication
        /*
         var sdkOptions = SDKClientOption()
         
         //SSL Certificates with password
         sdkOptions.SSL.Certificate = Bundle.main.path(forResource: "device.pfx", ofType: nil)
         sdkOptions.SSL.Password = "1234"
         
         //Offline Storage Configuration
         sdkOptions.OfflineStorage.AvailSpaceInMb = 0
         sdkOptions.OfflineStorage.Fil      eCount = 10
         
         //For Developer
         sdkOptions.discoveryUrl = "https://discovery.iotconnect.io"
         sdkOptions.debug = true
         
         //For SSL Enable Device Connection
         let objConfig = IoTConnectConfig(cpId: "nine", uniqueId: "iosss01", env: "QA", sdkOptions: sdkOptions)
         
         */
        
        //This code works for token base authentication
        //        let objConfig = IoTConnectConfig(cpId: "{replace-with-your-id}",
        //                                                 uniqueId: "{replace-with-your-id}",
        //                                                 env: .QA,
        //                                                 mqttConnectionType: .userCredntialAuthentication,
        //                                                 sdkOptions: nil)
        //        let objConfig = IoTConnectConfig(cpId: "qaiot106", uniqueId: "SmplDevice", env: .QA, mqttConnectionType: .userCredntialAuthentication, sdkOptions: nil)
        
        if !txtCPID.text!.isEmpty && !txtUniqueID.text!.isEmpty{
            self.viewLoader.isHidden = false
            let objConfig = IoTConnectConfig(cpId: txtCPID.text?.replacingOccurrences(of: " ", with: "") ?? "", uniqueId: txtUniqueID.text?.replacingOccurrences(of: " ", with: "")  ?? "", env: env, mqttConnectionType: .userCredntialAuthentication, sdkOptions: nil)
            
            SDKClient.shared.initialize(config: objConfig)
            
            SDKClient.shared.getDeviceCallBack { (message) in
                print("message: ", message as Any)
                DispatchQueue.main.async {
                    self.viewLoader.isHidden = true
                    self.txtView.text = "\(message ?? "")"
                    self.txtUniqueID.resignFirstResponder()
                    self.txtCPID.resignFirstResponder()
                }
                if let msg = message as? [String:Any]{
                    if let msg = msg["d"] as? [String:Any]{
                        if let commandType = msg["ct"] as? Int{
                            if commandType == CommandType.DEVICE_CONNECTION_STATUS{
                                if let command = msg["command"] as? Bool {
                                    if command == true{
                                        self.setConnectStatusUI()
                                    }else{
                                        self.setDisconnectUI()
                                    }
                                }
                            }else if commandType == CommandType.IDENTITIY_RESPONSE{
                                self.manageIdnetityreponse(response: msg)
                            }
                            else if  msg["ct"] as? Int == CommandType.GET_DEVICE_TEMPLATE_ATTRIBUTE{
                                print("Did recive 201 VC")
                                self.manageAttributeResponse(response: msg)
                            }
                            else   if  msg["ct"] as? Int == CommandType.GET_DEVICE_TEMPLATE_TWIN{
                                DispatchQueue.main.async {
                                    self.txtView.text = "\(msg)"
                                }
                            }else   if  msg["ct"] as? Int == CommandType.GET_CHILD_DEVICE{
                                if let msg = msg["d"] as? [[String:Any]]{
                                    self.noOfSecrions = msg.count
                                    self.is204Received = true
                                    print("no of sections \(msg.count)")
                                    self.arrChildDevicesAttributes = msg
                                    if !self.isGetDevicesCalled && self.is201Received{
                                        self.getChildDevicesAttributes()
                                    }
                                }
                                DispatchQueue.main.async {
                                    self.txtView.text = "\(msg)"
                                }
                            }
                        }
                    }
                    else if let msg = msg["sdkStatus"] as? String{
                        if msg == "error"{
                            self.presentAlert(title: "Error")
                            self.setDisconnectUI()
                        }
                    }
                    else if let commandType = msg["ct"] as? Int{
                        if commandType == CommandType.DEVICE_DELETED ||
                            commandType == CommandType.DEVICE_DISABLED ||
                            commandType == CommandType.DEVICE_RELEASED ||
                            commandType == CommandType.STOP_OPERATION ||
                            commandType == CommandType.DEVICE_CONNECTION_STATUS{
                            SDKClient.shared.dispose()
                            self.setDisconnectUI()
                        }else if commandType == CommandType.DEVICE_COMMAND{
                            self.sendAckMessage(cloudMsg: msg)
                        }else if commandType == CommandType.CORE_COMMAND{
                            SDKClient.shared.getAttributes { response in
                                print("Att reponse \(response)")
                                self.manageAttributeResponse(response: response as? [String : Any] ?? [:])
                            }
                        }
                    }
                    else if let msgError = msg["error"]{
                        DispatchQueue.main.async {
                            self.txtView.text = msgError as? String
                        }
                        self.setDisconnectUI()
                    }else{
                        print("Message \(msg)")
                    }
                }else if let msgData = message as? Data{
                    let dataDeviceTemp = try? JSONSerialization.jsonObject(with: msgData, options: .mutableContainers)
                    if dataDeviceTemp != nil {
                        let dataDevice = dataDeviceTemp as! [String:Any]
                        if let msg = dataDevice["d"] as? [String:Any]{
                            if let commandType = msg["ct"] as? Int{
                                if commandType == CommandType.IDENTITIY_RESPONSE{
                                    self.manageIdnetityreponse(response: dataDevice)
                                }
                            }
                        }
                    }
                }
            }
            
            SDKClient.shared.getTwinUpdateCallBack { (twinMessage) in
                print("twinMessage: ", twinMessage as Any)
                DispatchQueue.main.async {
                    self.txtView.text = "\(twinMessage ?? "")"
                }
            }
        }else{
            if txtCPID.text!.isEmpty{
                presentAlert(title: "Please enter CPID value")
            }else{
                presentAlert(title: "Please enter unique ID value")
            }
        }
    }
    
    func getSimpleDeviceData(){
//        print("index \(index)")
        var data = self.attributeData
        let attCount = data?.att?.count ?? 0
        var dCount = 0
        var arr = [[AttData]]()
        
        for i in 0...attCount-1{
            dCount += data?.att?[i].d?.count ?? 0
            
            let p = data?.att?[i].p
            print("simple device p \(String(describing: data?.att?[i])) \(String(describing: data?.att?[i].p))")
             
            if arr.count > 0{
                for k in 0...(data?.att?[i].d?.count ?? 0)-1{
                    data?.att?[i].d?[k].p = p
                    arr[0].insert((data?.att?[i].d?[k])!, at: arr[0].count)
                }
            }else{
                data?.att?[i].d?[i].p = p
                arr.append( (data?.att?[i].d)!)
            }
        }
        arrSimpleDeviceData.append(["Tag":arr])
        if arrSimpleDeviceData[0]["Tag"]?.count ?? 0 > 0{
            print("final arr \(arrSimpleDeviceData) \(arrSimpleDeviceData[0]["Tag"]?[0].count ?? 0)")
            noOfAttributes = arrSimpleDeviceData[0]["Tag"]?[0].count ?? 0
        }
    }

    func getParentArray(){
        let arrAttCount = self.attributeData?.att?.count
        var arr = [[AttData]]()
        let parentTag = self.identity?.d?.meta?.gtw?.tg
       
        for i in 0...(arrAttCount ?? 0)-1{
            let p = self.attributeData?.att![i].p
            var filteredArr = self.attributeData?.att![i].d?.filter({$0.tg == parentTag})
            print("filteredArr parent \(String(describing: filteredArr))")
            if filteredArr?.count ?? 0 > 0{
                for m in 0...(filteredArr!.count)-1{
                    filteredArr?[m].p = p
                }
                if arr.count > 0{
                    for k in 0...filteredArr!.count-1{
                        arr[0].insert((filteredArr?[k])!, at: arr[0].count)
                    }
                }else{
                    arr.append(filteredArr!)
                }
            }
        }
        arrParentData.append(["Tag":arr])
        if arrParentData[0]["Tag"]?.count ?? 0 > 0{
            print("final parent filter arr \(arrParentData) \(arrParentData[0]["Tag"]?[0].count ?? 0)")
            noOfAttributes = arrParentData[0]["Tag"]?[0].count ?? 0
        }
        getTblViewHeight()
    }
    
    func getChildDevicesAttributes(){
        if self.arrChildDevicesAttributes?.count ?? 0 > 0 &&
            self.attributeData?.att?.count ?? 0 > 0{
            self.isGetDevicesCalled = true
            let arrAttCount = self.attributeData?.att?.count
            var arrAttData = [[AttData]]()
            
            for j in 0...(arrChildDevicesAttributes?.count ?? 0)-1{
                arrAttData.removeAll()
                for i in 0...(arrAttCount ?? 0)-1{
                    let p = self.attributeData?.att![i].p
                    var filteredArr = self.attributeData?.att![i].d?.filter({$0.tg == arrChildDevicesAttributes?[j]["tg"] as? String})
                    print("filteredArr \(String(describing: arrChildDevicesAttributes?[j]["tg"] as? String)) \(String(describing: filteredArr)) \(String(describing: self.attributeData?.att![i]))")
                    
                    if filteredArr?.count ?? 0 > 0{
                        print("filteredArr count is gt 0")
                        for m in 0...(filteredArr!.count)-1{
//                            self.attData?.att![i].d?[m].p = p
                            filteredArr?[m].p = p
                        }
                        print("filteredArr \(String(describing: filteredArr))")
                        if arrAttData.count > 0{
                            for k in 0...filteredArr!.count-1{
                                arrAttData[0].insert((filteredArr?[k])!, at: arrAttData[0].count)
                            }
                        }else{
                            arrAttData.append(filteredArr!)
                        }
                    }
                }
                arrChildAttributeData.append(["Tag":arrAttData])
            }
            print("arrAttCount \(arrAttCount ?? 0)")
            print("final filter arr \(arrChildAttributeData) \(arrChildAttributeData.count)")
            self.getParentArray()
        }else{
            print("arrChildDevices count is 0")
            getParentArray()
        }
    }
    
    func loadData(data:[[String:[[AttData]]]]){
        var dict = [String:Any]()
        var arrDictForChildDevices = [[String:Any]]()
        var finalDict = [String:Any]()
        
        let sections = noOfSecrions == 0 ? 0 : noOfSecrions - 1
        
        for i in 0...sections{
            let arrAttData =  data[i]["Tag"]?[0]
            var dataSection = [String:Any]()
            
            if self.arrChildDevicesAttributes?.count ?? 0 > 0{
                dataSection = self.arrChildDevicesAttributes?[i] ?? [:]
            }

            if self.arrChildDevicesAttributes?.count ?? 0 > 0 &&
                self.attributeData?.att?.count ?? 0 > 0{
                for j in 0...(arrAttData?.count ?? 0)-1{
                    if arrAttData?[j].p?.isEmpty == true ||
                        arrAttData?[j].p == nil{
                        print("data dict load data \(dict)")
                        arrDictForChildDevices.append(["dt":now(),
                                                       "id":dataSection["id"] ?? "","tg":arrAttData?[j].tg ?? "","d":["\(arrAttData?[j].ln! ?? "")":arrAttData?[j].value ?? ""]])
                        print("arr data dict load data p nil \(arrDictForChildDevices)")
                    }else{
                        let arr = arrDictForChildDevices.filter{item in
                            if let itemd = item["d"] as?[String:Any]{
                                if let _ = itemd["\(arrAttData?[j].p ?? "")"] as? [String:Any]{
                                   return true
                                }
                            }
                            return false
                        }
                        
                        if arr.count > 0{
                            print("\(arrAttData?[j].p ?? "") exist \(arr) \(arrDictForChildDevices[arrDictForChildDevices.count-1]["d"] ?? "")" )
                            
                            var prevValD = arrDictForChildDevices[arrDictForChildDevices.count-1]["d"] as? [String:Any]
                            
                            let val = prevValD?[arrAttData?[j].p ?? ""] as? [String:Any]
                            let newVal = ["\(arrAttData?[j].ln! ?? "")":arrAttData?[j].value ?? ""] as? [String:Any]
                            
                            prevValD?[arrAttData?[j].p ?? ""] = val?.merging(newVal ?? [:], uniquingKeysWith: { current, _ in
                                return current
                            })
                            
                            arrDictForChildDevices[arrDictForChildDevices.count-1]["d"] = prevValD
                            print("child data dict load data \(arrDictForChildDevices)")
                        }else{
                            arrDictForChildDevices.append(["dt":now(),
                                                           "id":dataSection["id"] ?? "","tg":arrAttData?[j].tg ?? "","d":["\(arrAttData?[j].p ?? "")":["\(arrAttData?[j].ln! ?? "")":arrAttData?[j].value ?? ""]]])
                            print("arr data dict load data p \(arrDictForChildDevices)")
                        }
                    }
                }
            }else{
                let parentTag = self.identity?.d?.meta?.gtw?.tg ?? ""
                for j in 0...(arrAttData?.count ?? 0)-1{
                    if arrAttData?[j].p?.isEmpty == true ||
                        arrAttData?[j].p == nil{
                        dict.append(anotherDict:  ["\(arrAttData?[j].ln! ?? "")": arrAttData?[j].value ?? ""])
                        print("data dict load data \(dict)")
                    }else{
                        if dict["\(arrAttData?[j].p ?? "")"] != nil{//arrAttData?[j].p{
                            let val = dict["\(arrAttData?[j].p ?? "")"] as? [String:Any]
                            let newVal = ["\(arrAttData?[j].ln! ?? "")":arrAttData?[j].value ?? ""] as? [String:Any]
                            
                            dict[(arrAttData?[j].p)!] = val?.merging(newVal ?? [:], uniquingKeysWith: { current, _ in
                                return current
                            })
                            print("data dict load data p-1 \(dict)")
                        }else{
                            dict.updateValue(["\(arrAttData?[j].ln! ?? "")":arrAttData?[j].value ?? ""], forKey:"\(arrAttData?[j].p ?? "")")
                            print("data dict load data p \(dict)")
                        }
                    }
                }
                
                finalDict = ["dt":now(),
                                 "d":[["dt":now(),
                                      "id":txtUniqueID.text ?? "",
                                      "tg":parentTag,
                                       "d":dict]]] as [String : Any]
            }
        }
        
        if arrParentData.count > 0 &&
          self.arrChildDevicesAttributes?.count ?? 0 > 0{
            var dictParentData = [String:Any]()
            let parentData = arrParentData[0]["Tag"]
            let arrData = parentData?[0]
 
            for k in 0...(arrData?.count ?? 0)-1{
                //                print("arrParentData \(arrParentData[k])")
                if arrData?[k].p?.isEmpty == true ||
                    arrData?[k].p == nil{
                    dictParentData.append(anotherDict:  ["\(arrData?[k].ln! ?? "")": arrData?[k].value ?? ""])
                }else{
                     if dictParentData["\(arrData?[k].p ?? "")"] != nil{//arrAttData?[j].p{
                        let val = dictParentData["\(arrData?[k].p ?? "")"] as? [String:Any]
                        let newVal = ["\(arrData?[k].ln! ?? "")":arrData?[k].value ?? ""] as? [String:Any]
                        
                        dictParentData[(arrData?[k].p)!] = val?.merging(newVal ?? [:], uniquingKeysWith: { current, _ in
                            return current
                        })
                        print("data dict load data p-1 \(dict)")
                    }else{
                        dictParentData.updateValue(["\(arrData?[k].ln! ?? "")":arrData?[k].value ?? ""], forKey:"\(arrData?[k].p ?? "")")
                        print("data dict load data p \(dict)")
                    }
                }
            }
            dictParentData = [ "dt": now(),
                               "id": txtUniqueID.text ?? "",
                               "tg": arrData?[0].tg ?? "",
                               "d":dictParentData]
            arrDictForChildDevices.append(dictParentData)
            finalDict = ["dt":now(),
                         "d":arrDictForChildDevices]
        }
       
        print("finalDict \(finalDict)")
        DispatchQueue.main.async {
            self.viewLoader.isHidden = true
        }
        SDKClient.shared.sendData(data: finalDict)
    }
    
    func manageIdnetityreponse(response:[String:Any]){
        let dataIdentityResponse = try? JSONSerialization.data(withJSONObject: response)
        if dataIdentityResponse != nil{
            if let jsonData = try? JSONDecoder().decode(Identity.self, from: dataIdentityResponse!) {
                self.identity = jsonData
                if let meta = self.identity?.d?.meta{
                    if meta.gtw != nil{
                        isDeviceGateway = true
                        if let has = self.identity?.d?.has{
                            if let d = has.d, d == 1{
                                is204WillCalled = true
                            }
                        }
                    }else{
                        isDeviceGateway = false
                    }
                    if meta.edge ?? 0 == 1{
                        isDeviceEdge = true
                    }else{
                        isDeviceEdge = false
                    }
                }
            } else {
              print("Error parsing syncCall Response")
            }
        }
    }
    
    func manageAttributeResponse(response:[String:Any]){
        self.dictAttributes = response
        do {
            let json = try JSONSerialization.data(withJSONObject: response)
            let decoder = JSONDecoder()
            let decodedAttributes = try decoder.decode(AttributesData.self, from: json)
            //                                 print(" atrributes \(decodedAttributes.att)")
            self.attributeData = decodedAttributes
            let att = self.attributeData?.att
            self.is201Received = true
            //|| att?[0].tg?.isEmpty == true
//                                if (att?[0].tg == nil) && !self.isGetDevicesCalled{
            if !self.is204WillCalled{
                self.is204Received = true
            }
            if !self.isGetDevicesCalled && !self.isDeviceGateway{
//                                    self.is204Received = true
                self.isGetDevicesCalled = true
                self.getSimpleDeviceData()
            }
            else if !self.isGetDevicesCalled && self.is204Received{
                self.noOfAttributes = 0
                for i in 0...(att?.count ?? 0)-1{
                    let d = att?[i].d
                    self.noOfAttributes += d?.count ?? 0
                }
                self.getChildDevicesAttributes()
            }
//                                print("d count \(self.noOfAttributes)")
            DispatchQueue.main.async {
                self.tblProperty.isHidden = false
                self.getTblViewHeight()
            }
            self.enableMessageBtns()
        } catch {
            print(error)
        }
    }
    
    func sendAckMessage(cloudMsg:[String:Any]){
        SDKClient.shared.sendAckCmd(ackGuid: cloudMsg["ack"] as? String ?? "", status: "6",msg: "Cloud message received",childId: cloudMsg["id"] as? String ?? "")
    }
    
    func getTblViewHeight(){
        var totalCount = noOfSecrions
        totalCount += noOfAttributes + 1 //1 for headerview
        
        if noOfSecrions > 0,arrChildAttributeData.count>0{
            for i in 0...noOfSecrions-1{
                    if arrChildAttributeData[i]["Tag"]?.count ?? 0 > 0{
                        totalCount += arrChildAttributeData[i]["Tag"]?[0].count ?? 0
                    }
            }
        }
     
        tblViewHeightConstraint.constant =  Double(totalCount) * tblViewRowheight
        print("total rows \(totalCount)")
        DispatchQueue.main.async {
            self.tblProperty.reloadData()
        }
    }
    
    func setDisconnectUI(){
        self.noOfSecrions = 0
        self.noOfAttributes = 0
        self.isGetDevicesCalled = false
        self.arrChildDevicesAttributes?.removeAll()
        self.arrChildAttributeData.removeAll()
        self.arrParentData.removeAll()
        self.arrSimpleDeviceData.removeAll()
        self.is201Received = false
        self.is204Received = false
        self.isDeviceGateway = false
        self.identity = nil
        self.is204WillCalled = false
        DispatchQueue.main.async {
            self.devivceStatus = .disconnected
            self.btnConnect.setTitle(self.btnConnectTitle, for: .normal)
            self.btnStatus.backgroundColor = .red
            self.lblStatus.text = statusText.disconnected.rawValue
            self.viewLblTag.isHidden = true
            self.tblProperty.isHidden = true
            self.btnChildDevicesOperation.isEnabled = false
        }
        disableMsgBtns()
    }
    
    func setConnectStatusUI(boolBtnEnable:Bool = false){
        DispatchQueue.main.async {
            self.devivceStatus = .connected
            self.btnConnect.setTitle(self.btnDisConnectTitle, for: .normal)
            self.btnStatus.backgroundColor = .green
            self.lblStatus.text = statusText.connected.rawValue
            
            if boolBtnEnable{
                self.enableMessageBtns()
            }
        }
    }
    
    func enableMessageBtns(){
        manageBtnControl(btn: self.btnGetTwins, isEnable: true)
        manageBtnControl(btn: self.btnSendData, isEnable: true)
    }
    
    func disableMsgBtns(){
        manageBtnControl(btn: self.btnGetTwins, isEnable: false)
        manageBtnControl(btn: self.btnSendData, isEnable: false)
    }
    
    func manageBtnControl(btn:UIButton,isEnable:Bool){
        DispatchQueue.main.async {
            btn.isEnabled = isEnable
            if isEnable{
                btn.backgroundColor = .systemBlue
                btn.setTitleColor(.white, for: .normal)
            }else{
                btn.backgroundColor = .systemGray3
                btn.setTitleColor(.darkGray, for: .normal)
            }
        }
    }

    func presentAlert(title:String = "",msg:String = ""){
        DispatchQueue.main.async {
            let alertVC = UIAlertController (title: title, message: msg, preferredStyle: .alert)
            let okAction = UIAlertAction (title: "OK", style: .default)
            alertVC.addAction(okAction)
            self.present(alertVC, animated: true)
        }
    }
    
    func now() -> String {
        return toString(fromDateTime: Date())
    }
    private func toString(fromDateTime datetime: Date?) -> String {
        // Purpose: Return a string of the specified date-time in UTC (Zulu) time zone in ISO 8601 format.
        // Example: 2013-10-25T06:59:43.431Z
        let dateFormatter = DateFormatter()
        if let anAbbreviation = NSTimeZone(abbreviation: "UTC") {
            dateFormatter.timeZone = anAbbreviation as TimeZone
        }
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        var dateTimeInIsoFormatForZuluTimeZone: String? = nil
        if let aDatetime = datetime {
            dateTimeInIsoFormatForZuluTimeZone = dateFormatter.string(from: aDatetime)
        }
        return dateTimeInIsoFormatForZuluTimeZone!
    }

    
    //MARK: IBAction events
    
    @IBAction func btnConnectTapped(_ sender: Any) {
        if self.devivceStatus == .disconnected{
            connectSDK()
        }else{
            SDKClient.shared.dispose()
        }
    }
    
    @IBAction func btnAvnetTapped(_ sender: UIButton) {
        radioController.buttonArrayUpdated(buttonSelected: sender)
        env = .AVNETPOC
    }
    
    @IBAction func btnPOCTapped(_ sender: UIButton) {
        env = .PROD
        radioController.buttonArrayUpdated(buttonSelected: sender)
    }
    
    @IBAction func btnQATapped(_ sender: UIButton) {
        env = .QA
        radioController.buttonArrayUpdated(buttonSelected: sender)
    }
    
    @IBAction func btnDevTapped(_ sender: UIButton) {
        env = .DEV
        radioController.buttonArrayUpdated(buttonSelected: sender)
    }
    
    @IBAction func btnClearTapped(_ sender: Any) {
        self.txtView.text = ""
    }
    
    @IBAction func btnGetTwinsTapped(_ sender: Any) {
        //        SDKClient.shared.getAllTwins()
        //        SDKClient.shared.getTwinUpdateCallBack { (twinMessage) in
        //            print("twinMessage: ", twinMessage as Any)
        //            DispatchQueue.main.async {
        //                self.txtView.text = "\(twinMessage ?? "")"
        //            }
        //        }
        
//        SDKClient.shared.getTwins(callBack: {(message) in
//            print("Get twins callback message \(message)")
//        })
        
//        SDKClient.shared.getChildDevices(callBack: {(message) in
//            print("Get child device callback message \(message)")
//        })
       
    }
    
    @IBAction func btnSendDataTapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.viewLoader.isHidden = false
        }
        if self.arrChildAttributeData.count > 0{
            loadData(data: arrChildAttributeData)
        }else if arrParentData.count > 0{
            loadData(data: arrParentData)
        }else if arrSimpleDeviceData.count > 0{
            loadData(data: arrSimpleDeviceData)
        }
        
//        SDKClient.shared.getAttributes { resposnse in
//            print("Did recive 201 Attribute response \(resposnse)")
//        }
        
        
    }
    
}

extension UITextField {
    
    func addUnderLine () {
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0.0, y: self.bounds.height + 3, width: self.bounds.width, height: 1.5)
        bottomLine.backgroundColor = UIColor.lightGray.cgColor
        
        self.borderStyle = UITextField.BorderStyle.none
        self.layer.addSublayer(bottomLine)
    }
    
}

extension ViewController: UITableViewDelegate,UITableViewDataSource {
    
        func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
            return 0.0
        }
    
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return tblViewRowheight
        }
        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableHeaderView") as! TableHeaderView
//            if section == 0 {
//                headerView.lblSectionTitle.text = "Section 1"
//            } else {
//                headerView.lblSectionTitle.text = "Section 2"
//            }
            if self.arrChildDevicesAttributes?.count ?? 0 <= section{
                headerView.lblSectionTitle.text = "TAG::p:\(self.txtUniqueID.text ?? "")"
            }else{
                let data = self.arrChildDevicesAttributes?[section]
                headerView.lblSectionTitle.text = "TAG::\(data?["tg"] ?? ""):\(data?["id"] ?? "")"
            }
          
            let view = UIView()
            headerView.frame.size.width = tableView.frame.size.width
            view.frame = headerView.frame
//            view.backgroundColor = .clear
            view.isUserInteractionEnabled = true
            view.addSubview(headerView)
            return view
        }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.arrChildDevicesAttributes?.count ?? 0 > section,arrChildAttributeData.count > 0{
            if arrChildAttributeData[section]["Tag"]?.count ?? 0 > 0{
                return arrChildAttributeData[section]["Tag"]?[0].count ?? 0
            }else{
                return 0
            }
        }
        return noOfAttributes
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return noOfSecrions+1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tblViewRowheight
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : PropertyCell = tableView.dequeueReusableCell(withIdentifier: "PropertyCell", for: indexPath) as! PropertyCell
        cell.selectionStyle = .none
        cell.txtField.delegate = self
//        cell.textLabel?.text = "\(indexPath.row)"
        if self.arrChildDevicesAttributes?.count ?? 0 > indexPath.section{
            cell.setAttData(data: (arrChildAttributeData[indexPath.section]["Tag"]?[0])!,index: indexPath.row)
        }else if arrParentData.count > 0{
            cell.setAttData(data: (arrParentData[0]["Tag"]?[0])!,index: indexPath.row)
        }else if arrSimpleDeviceData.count > 0{
            cell.setAttData(data: (arrSimpleDeviceData[0]["Tag"]?[0])!,index: indexPath.row)
//            if let data = self.attData{
//                cell.setData(model: data,index: indexPath.item)
//            }
        }

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("dids select ")
    }
}

extension ViewController:UITextFieldDelegate{
    
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        
//    }
//    
//    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
//        var v : UIView = textField
//        repeat { v = v.superview! } while !(v is UITableViewCell)
//        let cell = v as! PropertyCell // or UITableViewCell or whatever
//        let ip = self.tblProperty.indexPath(for:cell)!
//        print("textFieldDidEndEditing \(textField.text) \(ip.section) \(ip.row)")
//    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var v : UIView = textField
        repeat { v = v.superview! } while !(v is UITableViewCell)
        let cell = v as! PropertyCell // or UITableViewCell or whatever
        let ip = self.tblProperty.indexPath(for:cell)!
//        print("txtField \(string) \(textField.text ?? "")  \(textField.text ?? "")\(string) \(ip.section) \(ip.row)")
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            if self.arrChildDevicesAttributes?.count ?? 0 > ip.section{
                arrChildAttributeData[ip.section]["Tag"]?[0][ip.row].value = updatedText
            }else if arrParentData.count > 0{
                arrParentData[0]["Tag"]?[0][ip.row].value = updatedText
//                arrParentData[0]["Tag"]?[0][0].value = updatedText
            }else if arrSimpleDeviceData.count > 0{
                arrSimpleDeviceData[ip.section]["Tag"]?[0][ip.row].value = updatedText
            }
        }
        return true
    }
}



extension Dictionary where Key == String, Value == Any {
    
    mutating func append(anotherDict:[String:Any]) {
        for (key, value) in anotherDict {
            self.updateValue(value, forKey: key)
        }
    }
}
