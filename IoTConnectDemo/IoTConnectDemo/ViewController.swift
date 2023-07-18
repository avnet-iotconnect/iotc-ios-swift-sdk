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
    //    @IBOutlet var heightTableConstraint : NSLayoutConstraint!
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
    
    //MARK:Variable
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
    var attData:AttributesData?
    private var arrChildDevices:[[String:Any]]?
    private var isGetDevicesCalled = false
    private var arrData = [[String:[[AttData]]]]()
    private var arrParentData = [[String:[[AttData]]]]()
    private var arrDeviceData = [[String:[[AttData]]]]()
    private var is201Received:Bool = false
    private var is204Received:Bool = false
    private var identity:Identity?
    private var isDeviceGateway = false
    private var isDeviceEdge = false
    private var is204WillCalled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        radioController.buttonsArray = [btnAvnet,btnQA,btnDev,btnPOC]
        radioController.defaultButton = btnQA
        
        //button Status Corner Radius
        btnStatus.layer.cornerRadius = 12.5
        
        //Register Table Header View
        let nib = UINib(nibName: "TableHeaderView", bundle: nil)
        tblProperty.register(nib, forHeaderFooterViewReuseIdentifier: "TableHeaderView")
//        let isValid = checkValInRange(arrRange: [1,10], value: 10.0)
//        print("\(isValid)")
//        checkDate()
        
//        if let floatVal = Float("12:45:15"){
//            print("Valid value")
//        }else{
//            print("InValid Value")
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Add Underline textfield
        self.txtCPID.addUnderLine()
        self.txtUniqueID.addUnderLine()
        
        txtView.layer.cornerRadius = 10
        txtView.layer.borderWidth = 1
        txtView.layer.borderColor = UIColor.darkGray.cgColor
        
        //        heightTableConstraint.constant = (20*44) + 80
    }
    
//    func checkDate(){
//
//        let dateFormatter = DateFormatter()
////        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
//        if let date = dateFormatter.date(from:"2016-06-23T09:07:21.000Z"){
//            print("valid date")
//        }
//
////        let formatter = Foundation.DateFormatter()
////        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'" //2017-04-01T18:05:00.000//2016-06-23T09:07:21.000Z
////            //"2017-04-01T18:05:00.000Z"
////        let date1  = formatter.date(from:"2016-06-23T09:07:21.000Z")
////        print("date:\(String(describing: date1))")
////        formatter.dateFormat = "HH:mm"
////        let resultTime = formatter.string(from: date1!)
////        print("time:\(String(describing: resultTime))")
//    }
    
//    func checkValInRange<T:Comparable>(arrRange:[T],value:T)->Bool{
////        if let firstVal = arrRange[0].trimmingCharacters(in: .whitespaces) ,let seccondVal = arrRange[1].trimmingCharacters(in: .whitespaces){
//            let range = arrRange[0]...arrRange[1]
//            if range.contains(value){
//                return true
//            }
////        }
//        return false
//    }
    
//    func splitString(){
//        let str = "1 to 10"
//        print(str.components(separatedBy: ","))
////        print(str.components(separatedBy: "to"))
//        var comp = str.components(separatedBy: ",")
//        var filter = comp.filter({$0.contains("to")})
//        print(filter)
//        var toArr = filter[0].components(separatedBy: "to")
//        comp.removeAll(where: {$0.contains("to")})
//        let range = (Int(toArr[0].trimmingCharacters(in:.whitespaces)) ?? 0)...(Int(toArr[1].trimmingCharacters(in: .whitespaces)) ?? 0)
//        print(range)
//    }
    
    //MARK: - Custom Methods
    //    @IBAction private func clickActions(sender: AnyObject) {
    //        if sender.isEqual(btnConnect) {
    //            if self.devivceStatus == .disconnected{
    //                connectSDK()
    //            }else{
    //                SDKClient.shared.dispose()
    //            }
    //
    //        }
    //    }
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
                                        //                                SDKClient.shared.getAttributes { resposnse in
                                        //                                    print("Did recive 201 Attribute response \(resposnse)")
                                        //                                }
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
//                                self.dictAttributes = msg
//                                do {
//                                    let json = try JSONSerialization.data(withJSONObject: msg)
//                                    let decoder = JSONDecoder()
//                                    let decodedAttributes = try decoder.decode(AttributesData.self, from: json)
//                                    //                                 print(" atrributes \(decodedAttributes.att)")
//                                    self.attData = decodedAttributes
//                                    let att = self.attData?.att
//                                    self.is201Received = true
//                                    //|| att?[0].tg?.isEmpty == true
//    //                                if (att?[0].tg == nil) && !self.isGetDevicesCalled{
//                                    if !self.is204WillCalled{
//                                        self.is204Received = true
//                                    }
//                                    if !self.isGetDevicesCalled && !self.isDeviceGateway{
//    //                                    self.is204Received = true
//                                        self.isGetDevicesCalled = true
//                                        self.getSimpleDeviceData()
//                                    }
//                                    else if !self.isGetDevicesCalled && self.is204Received{
//                                        self.noOfAttributes = 0
//                                        for i in 0...(att?.count ?? 0)-1{
//                                            let d = att?[i].d
//                                            self.noOfAttributes += d?.count ?? 0
//                                        }
//                                        self.getDevicesArray()
//                                    }
//    //                                print("d count \(self.noOfAttributes)")
//                                    DispatchQueue.main.async {
//                                        self.tblProperty.isHidden = false
//    //                                    self.viewLblTag.isHidden = false
//    //                                    self.lblTag.text = "TAG: \(self.txtUniqueID.text ?? "")"
//    //                                    self.tblViewHeightConstraint.constant = CGFloat(self.tblViewRowheight*Double(self.noOfAttributes))
//                                        self.getTblViewHeight()
//                                    }
//                                    self.enableMessageBtns()
//                                } catch {
//                                    print(error)
//                                }
                            }
                            else   if  msg["ct"] as? Int == 202{
                                DispatchQueue.main.async {
                                    self.txtView.text = "\(msg)"
                                }
                            }else   if  msg["ct"] as? Int == 204{
                                if let msg = msg["d"] as? [[String:Any]]{
                                    self.noOfSecrions = msg.count
                                    self.is204Received = true
                                    print("no of sections \(msg.count)")
                                    self.arrChildDevices = msg
                                    if !self.isGetDevicesCalled && self.is201Received{
                                        self.getDevicesArray()
                                    }
                                }
                                DispatchQueue.main.async {
                                    self.txtView.text = "\(msg)"
                                }
                            }
                        }
//                        if let command = msg["command"] as? Bool {
//                            if command == true{
//                                self.setConnectStatusUI()
////                                SDKClient.shared.getAttributes { resposnse in
////                                    print("Did recive 201 Attribute response \(resposnse)")
////                                }
//                            }else{
//                                self.setDisconnectUI()
//                            }
//                        }
                    }
                    else if let msg = msg["sdkStatus"] as? String{
                        if msg == "error"{
                            self.presentAlert(title: "Error")
                            self.setDisconnectUI()
                            //                            DispatchQueue.main.async {
                            //                                self.devivceStatus = .disconnected
                            //                                self.btnStatus.backgroundColor = .red
                            //                                self.lblStatus.text = statusText.disconnected.rawValue
                            //                                self.btnConnect.setTitle(self.btnConnectTitle, for: .normal)
                            //                            }
                        }
//                        else if msg == "connect"{
//                            self.setConnectStatusUI()
////                            DispatchQueue.main.async {
////                                self.viewLoader.isHidden = false
////                            }
////                            SDKClient.shared.getAttributes { isSuccess, dictData, msg in
////
////                            }
//                            //                            DispatchQueue.main.async {
//                            //                                self.devivceStatus = .connected
//                            //                                self.btnConnect.setTitle(self.btnDisConnectTitle, for: .normal)
//                            //                                self.btnStatus.backgroundColor = .green
//                            //                                self.lblStatus.text = statusText.connected.rawValue
//                            //                                SDKClient.shared.getAttributes { isSuccess, dictData, msg in
//                            //
//                            //                                }
//                            //                            }
//                        }else if msg == "DidDisconnect"{
//                            self.setDisconnectUI()
//                            //                            DispatchQueue.main.async {
//                            //                                self.devivceStatus = .disconnected
//                            //                                self.btnConnect.setTitle(self.btnConnectTitle, for: .normal)
//                            //                                self.btnStatus.backgroundColor = .red
//                            //                                self.lblStatus.text = statusText.disconnected.rawValue
//                            //                            }
//                        }else if msg == "WillDisconnect"{
//                            SDKClient.shared.dispose()
//                        }
                    }
//                    else if let msg = msg["d"] as? [String:Any]{
////                        print("Did receive message \(msg)")
////                        if  msg["ct"] as? Int == 201{
////                            print("Did recive 201 VC")
////                            self.dictAttributes = msg
////                            do {
////                                let json = try JSONSerialization.data(withJSONObject: msg)
////                                let decoder = JSONDecoder()
////                                let decodedAttributes = try decoder.decode(AttributesData.self, from: json)
////                                //                                 print(" atrributes \(decodedAttributes.att)")
////                                self.attData = decodedAttributes
////                                let att = self.attData?.att
////                                self.is201Received = true
////                                //|| att?[0].tg?.isEmpty == true
//////                                if (att?[0].tg == nil) && !self.isGetDevicesCalled{
////                                if !self.is204WillCalled{
////                                    self.is204Received = true
////                                }
////                                if !self.isGetDevicesCalled && !self.isDeviceGateway{
//////                                    self.is204Received = true
////                                    self.isGetDevicesCalled = true
////                                    self.getSimpleDeviceData()
////                                }
////                                else if !self.isGetDevicesCalled && self.is204Received{
////                                    self.noOfAttributes = 0
////                                    for i in 0...(att?.count ?? 0)-1{
////                                        let d = att?[i].d
////                                        self.noOfAttributes += d?.count ?? 0
////                                    }
////                                    self.getDevicesArray()
////                                }
//////                                print("d count \(self.noOfAttributes)")
////                                DispatchQueue.main.async {
////                                    self.tblProperty.isHidden = false
//////                                    self.viewLblTag.isHidden = false
//////                                    self.lblTag.text = "TAG: \(self.txtUniqueID.text ?? "")"
//////                                    self.tblViewHeightConstraint.constant = CGFloat(self.tblViewRowheight*Double(self.noOfAttributes))
////                                    self.getTblViewHeight()
////                                }
////                                self.enableMessageBtns()
////                            } catch {
////                                print(error)
////                            }
////                        }
////                        else   if  msg["ct"] as? Int == 202{
////                            DispatchQueue.main.async {
////                                self.txtView.text = "\(msg)"
////                            }
////                        }else   if  msg["ct"] as? Int == 204{
////                            if let msg = msg["d"] as? [[String:Any]]{
////                                self.noOfSecrions = msg.count
////                                self.is204Received = true
////                                print("no of sections \(msg.count)")
////                                self.arrChildDevices = msg
////                                if !self.isGetDevicesCalled && self.is201Received{
////                                    self.getDevicesArray()
////                                }
////                            }
////                            DispatchQueue.main.async {
////                                self.txtView.text = "\(msg)"
////                            }
////                        }
//                    }
                    else if let msg = msg["ct"] as? Int{
                        if msg == 106 ||
                            msg == 107 ||
                            msg == 108 ||
                            msg == 109 ||
                            msg == 116{
                            SDKClient.shared.dispose()
                            self.setDisconnectUI()
                            //                            DispatchQueue.main.async {
                            //                                SDKClient.shared.dispose()
                            //                                self.devivceStatus = .disconnected
                            //                                self.btnConnect.setTitle(self.btnConnectTitle, for: .normal)
                            //                                self.btnStatus.backgroundColor = .red
                            //                                self.lblStatus.text = statusText.disconnected.rawValue
                            //                            }
                        }
                    }
                    else if let msg = msg["error"]{
                        DispatchQueue.main.async {
                            self.txtView.text = msg as? String
                        }
                        self.setDisconnectUI()
                    }else{
                        print("Message \(msg)")
                    }
                }else if let msg = message as? Data{
                    let dataDeviceTemp = try? JSONSerialization.jsonObject(with: msg, options: .mutableContainers)
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
                    self.txtView.text = "\(twinMessage)"
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
        var data = self.attData
        let attCount = data?.att?.count ?? 0
        var dCount = 0
        var arr = [[AttData]]()
        
        for i in 0...attCount-1{
//            arr.removeAll()
            dCount += data?.att?[i].d?.count ?? 0
            
            let p = data?.att?[i].p
            print("simple device p \(data?.att?[i]) \(data?.att?[i].p)")
             
            if arr.count > 0{
                for k in 0...(data?.att?[i].d?.count ?? 0)-1{
                    data?.att?[i].d?[k].p = p
                    arr[0].insert((data?.att?[i].d?[k])!, at: arr[0].count)
                }
//                arr.insert((data?.att?[i].d)!, at: arr.count)
            }else{
                data?.att?[i].d?[i].p = p
                arr.append( (data?.att?[i].d)!)
            }
            
//            if index <= dCount-1{
//                let attDCount = model.att?[i].d?.count ?? 0
//                var dIndex = index
//                if dCount != attDCount{
//                    dIndex = (dCount - (index+1))-1
////                    print("att index \(i) index \(index) dIndex \(dIndex)")
//                    if dIndex == -1{
//                        if dCount == index + 1{
//                            dIndex = attDCount-1
//                        }else{
//                            dIndex = index-1
//                        }
//                    }
//                }
//
//                data?.att?[i].d?[dIndex].p =  model.att?[i].p
//
//                if arr.count > 0{
//                    arr.insert((data?.att?[i].d)!, at: arr.count)
//                }else{
//                    arr.append( (data?.att?[i].d)!)
//                }
//
//                let parentName = model.att?[i].p
//                let ln = model.att?[i].d?[dIndex].ln
////                self.txtField.placeholder = !(parentName?.isEmpty ?? true) ? "\(parentName ?? ""):\(ln ?? "")" : "\(ln ?? "")"
////                print("placeholder \(self.txtField.placeholder ?? "")")
//                break
//            }else{
//                continue
//            }
        }
        arrDeviceData.append(["Tag":arr])
        if arrDeviceData[0]["Tag"]?.count ?? 0 > 0{
            print("final arr \(arrDeviceData) \(arrDeviceData[0]["Tag"]?[0].count ?? 0)")
            noOfAttributes = arrDeviceData[0]["Tag"]?[0].count ?? 0
        }
    }

    func getParentArray(){
        let arrAttCount = self.attData?.att?.count
        var arr = [[AttData]]()
        let parentTag = self.identity?.d?.meta?.gtw?.tg
        // let p = data?.att?[i].p AttData?[m].p
        
        for i in 0...(arrAttCount ?? 0)-1{
            let p = self.attData?.att![i].p
            var filteredArr = self.attData?.att![i].d?.filter({$0.tg == parentTag})
            print("filteredArr parent \(String(describing: filteredArr))")
            if filteredArr?.count ?? 0 > 0{
                for m in 0...(filteredArr!.count)-1{
//                            self.attData?.att![i].d?[m].p = p
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
    
    func getDevicesArray(){
        if self.arrChildDevices?.count ?? 0 > 0 &&
            self.attData?.att?.count ?? 0 > 0{
            self.isGetDevicesCalled = true
            let arrAttCount = self.attData?.att?.count
            var arr = [[AttData]]()
            
            for j in 0...(arrChildDevices?.count ?? 0)-1{
                //                print("j \(j)")
                arr.removeAll()
                for i in 0...(arrAttCount ?? 0)-1{
                    let p = self.attData?.att![i].p
                    var filteredArr = self.attData?.att![i].d?.filter({$0.tg == arrChildDevices?[j]["tg"] as? String})
                    print("filteredArr \(String(describing: arrChildDevices?[j]["tg"] as? String)) \(String(describing: filteredArr)) \(String(describing: self.attData?.att![i]))")
                
                    if filteredArr?.count ?? 0 > 0{
                        print("filteredArr count is gt 0")
                        for m in 0...(filteredArr!.count)-1{
//                            self.attData?.att![i].d?[m].p = p
                            filteredArr?[m].p = p
                        }
                        print("filteredArr \(String(describing: filteredArr))")
                        if arr.count > 0{
                            for k in 0...filteredArr!.count-1{
                                arr[0].insert((filteredArr?[k])!, at: arr[0].count)
                            }
                        }else{
                            arr.append(filteredArr!)
                        }
                    }
                }
                arrData.append(["Tag":arr])
            }
            print("arrAttCount \(arrAttCount)")
            print("final filter arr \(arrData) \(arrData.count)")
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
            
            if self.arrChildDevices?.count ?? 0 > 0{
                dataSection = self.arrChildDevices?[i] ?? [:]
            }

            if self.arrChildDevices?.count ?? 0 > 0 &&
                self.attData?.att?.count ?? 0 > 0{
              
                for j in 0...(arrAttData?.count ?? 0)-1{
//                    print("child devices \(i) \(self.arrChildDevices?.count) \(arrAttData) \(arrAttData?[j])")
                    if arrAttData?[j].p?.isEmpty == true ||
                        arrAttData?[j].p == nil{
                        print("data dict load data \(dict)")
                        arrDictForChildDevices.append(["dt":now(),"id":dataSection["id"] ?? "","tg":arrAttData?[j].tg ?? "","d":["\(arrAttData?[j].ln! ?? "")":arrAttData?[j].value ?? ""]])
//                        arrDictForChildDevices.append(["dt":now(),"id":dataSection["id"] ?? "","tg":arrAttData?[j].tg ?? "","d":["\(arrAttData?[j].p ?? "")":["\(arrAttData?[j].ln! ?? "")":arrAttData?[j].value ?? ""]]])
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
                            print("\(arrAttData?[j].p ?? "") exist \(arr) \(arrDictForChildDevices[arrDictForChildDevices.count-1]["d"])" )
                            
                            var prevValD = arrDictForChildDevices[arrDictForChildDevices.count-1]["d"] as? [String:Any]
                            
                            let val = prevValD?[arrAttData?[j].p ?? ""] as? [String:Any]
                            let newVal = ["\(arrAttData?[j].ln! ?? "")":arrAttData?[j].value ?? ""] as? [String:Any]
                            
                            prevValD?[arrAttData?[j].p ?? ""] = val?.merging(newVal ?? [:], uniquingKeysWith: { current, _ in
                                return current
                            })
                            
                            arrDictForChildDevices[arrDictForChildDevices.count-1]["d"] = prevValD
                            print("child data dict load data \(arrDictForChildDevices)")
                        }else{
                            arrDictForChildDevices.append(["dt":now(),"id":dataSection["id"] ?? "","tg":arrAttData?[j].tg ?? "","d":["\(arrAttData?[j].p ?? "")":["\(arrAttData?[j].ln! ?? "")":arrAttData?[j].value ?? ""]]])
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
          self.arrChildDevices?.count ?? 0 > 0{
            var dictParentData = [String:Any]()
            let parentData = arrParentData[0]["Tag"]
            let arrData = parentData?[0]
            
//            let arr = arrData.filter{item in
//                if let itemd = item["d"] as?[String:Any]{
////                    if let _ = itemd["\(arrAttData?[j].p ?? "")"] as? [String:Any]{
//                       return true
////                    }
//                }
//                return false
//            }
            
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
                
                
                
                
                //                if dictParentData.isEmpty{
                ////                    dictParentData = ["d":[arrData?[k].ln ?? "":arrData?[k].value ?? ""]]
                //                    dictParentData = [arrData?[k].ln ?? "":arrData?[k].value ?? ""]
                //                }else{
                //                    dictParentData.append(anotherDict: [arrData?[k].ln ?? "":arrData?[k].value ?? ""])
                ////                    let val = dict["d"] as? [String:Any]
                ////                    let newVal = ["\(arrData?[k].ln! ?? "")":arrData?[k].value ?? ""] as? [String:Any]
                ////                    dict["d"] = val?.merging(newVal ?? [:], uniquingKeysWith: { current, _ in
                ////                        return current
                ////                    })
                //                }
                ////                arrDictForChildDevices.append(["dt":now(),"id":txtUniqueID.text ?? "","tg":arrData?[k].tg ?? "","d":[arrData?[k].ln ?? "":arrData?[k].value ?? ""]])
                ////                print("arrDictForChildDevices parentData \(arrDictForChildDevices)")
                //            }
            }
            dictParentData = [ "dt": now(),
                               "id": txtUniqueID.text ?? "",
                                     "tg": arrData?[0].tg ?? "","d":dictParentData]
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
        }else{
            
        }
    }
    
    func manageAttributeResponse(response:[String:Any]){
        self.dictAttributes = response
        do {
            let json = try JSONSerialization.data(withJSONObject: response)
            let decoder = JSONDecoder()
            let decodedAttributes = try decoder.decode(AttributesData.self, from: json)
            //                                 print(" atrributes \(decodedAttributes.att)")
            self.attData = decodedAttributes
            let att = self.attData?.att
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
                self.getDevicesArray()
            }
//                                print("d count \(self.noOfAttributes)")
            DispatchQueue.main.async {
                self.tblProperty.isHidden = false
//                                    self.viewLblTag.isHidden = false
//                                    self.lblTag.text = "TAG: \(self.txtUniqueID.text ?? "")"
//                                    self.tblViewHeightConstraint.constant = CGFloat(self.tblViewRowheight*Double(self.noOfAttributes))
                self.getTblViewHeight()
            }
            self.enableMessageBtns()
        } catch {
            print(error)
        }
    }
    
    func getTblViewHeight(){
        var totalCount = noOfSecrions
        totalCount += noOfAttributes + 1 //1 for headerview
        
        if noOfSecrions > 0,arrData.count>0{
            for i in 0...noOfSecrions-1{
    //            for j in 0...arrData.count-1{
                    if arrData[i]["Tag"]?.count ?? 0 > 0{
                        totalCount += arrData[i]["Tag"]?[0].count ?? 0
                    }
    //            }
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
        self.arrChildDevices?.removeAll()
        self.arrData.removeAll()
        self.arrParentData.removeAll()
        self.arrDeviceData.removeAll()
        self.is201Received = false
        self.is201Received = false
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
            self.btnGetTwins.isEnabled = false
            self.btnChildDevicesOperation.isEnabled = false
            self.btnSendData.isEnabled = false
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
                self.btnGetTwins.isEnabled = true
                self.btnSendData.isEnabled = true
            }
        }
    }
    
    func enableMessageBtns(){
        DispatchQueue.main.async {
            self.btnGetTwins.isEnabled = true
            self.btnSendData.isEnabled = true
            self.btnSendData.backgroundColor = .systemBlue
            self.btnGetTwins.backgroundColor = .systemBlue
            self.btnSendData.setTitleColor(.white, for: .normal)
            self.btnGetTwins.setTitleColor(.white, for: .normal)
        }
    }
    
    func disableMsgBtns(){
        DispatchQueue.main.async {
            self.btnGetTwins.isEnabled = false
            self.btnSendData.isEnabled = false
            self.btnSendData.backgroundColor = .systemGray3
            self.btnGetTwins.backgroundColor = .systemGray3
            self.btnSendData.setTitleColor(.black, for: .normal)
            self.btnGetTwins.setTitleColor(.black, for: .normal)
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
        env = .POC
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
        if self.arrData.count > 0{
            loadData(data: arrData)
        }else if arrParentData.count > 0{
            loadData(data: arrParentData)
        }else if arrDeviceData.count > 0{
            loadData(data: arrDeviceData)
        }
        
//        if self.arrChildDevices?.count ?? 0 > indexPath.section{
//            cell.setAttData(data: (arrData[indexPath.section]["Tag"]?[0])!,index: indexPath.row)
//        }else if arrParentData.count > 0{
//            cell.setAttData(data: (arrParentData[0]["Tag"]?[0])!,index: indexPath.row)
//        }else if arrDeviceData.count > 0{
//            cell.setAttData(data: (arrDeviceData[0]["Tag"]?[0])!,index: indexPath.row)
////            if let data = self.attData{
////                cell.setData(model: data,index: indexPath.item)
////            }
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
            if self.arrChildDevices?.count ?? 0 <= section{
                headerView.lblSectionTitle.text = "TAG::p:\(self.txtUniqueID.text ?? "")"
            }else{
                let data = self.arrChildDevices?[section]
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
    //    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    //        return UIView()
    //    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                if self.arrChildDevices?.count ?? 0 > section{
                    if arrData[section]["Tag"]?.count ?? 0 > 0{
                        return arrData[section]["Tag"]?[0].count ?? 0
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
        if self.arrChildDevices?.count ?? 0 > indexPath.section{
            cell.setAttData(data: (arrData[indexPath.section]["Tag"]?[0])!,index: indexPath.row)
        }else if arrParentData.count > 0{
            cell.setAttData(data: (arrParentData[0]["Tag"]?[0])!,index: indexPath.row)
        }else if arrDeviceData.count > 0{
            cell.setAttData(data: (arrDeviceData[0]["Tag"]?[0])!,index: indexPath.row)
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
            if self.arrChildDevices?.count ?? 0 > ip.section{
                arrData[ip.section]["Tag"]?[0][ip.row].value = updatedText
            }else if arrParentData.count > 0{
                arrParentData[0]["Tag"]?[0][ip.row].value = updatedText
//                arrParentData[0]["Tag"]?[0][0].value = updatedText
            }else if arrDeviceData.count > 0{
                arrDeviceData[ip.section]["Tag"]?[0][ip.row].value = updatedText
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
