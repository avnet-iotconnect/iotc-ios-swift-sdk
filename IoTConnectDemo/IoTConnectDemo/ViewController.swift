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
    private var is201Received:Bool = false
    private var is204Received:Bool = false
    
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
        
        //        heightTableConstraint.constant = (20*44) + 80
    }
    
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
                    if let msg = msg["data"] as? [String:Any]{
                        if let command = msg["command"] as? Bool {
                            if command == true{
                                self.setConnectStatusUI()
//                                SDKClient.shared.getAttributes { isSuccess, dictData, msg in
//
//                                }
                            }else{
                                self.setDisconnectUI()
                            }
                        }
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
                    else if let msg = msg["d"] as? [String:Any]{
                        print("Did receive message \(msg)")
                        if  msg["ct"] as? Int == 201{
                            self.dictAttributes = msg
                            do {
                                let json = try JSONSerialization.data(withJSONObject: msg)
                                let decoder = JSONDecoder()
                                let decodedAttributes = try decoder.decode(AttributesData.self, from: json)
                                //                                 print(" atrributes \(decodedAttributes.att)")
                                self.attData = decodedAttributes
                                let att = self.attData?.att
                                self.is201Received = true
                                
                                if !self.isGetDevicesCalled && self.is204Received{
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
                        }else   if  msg["ct"] as? Int == 202{
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
    
    func getParentArray(){
        let arrAttCount = self.attData?.att?.count
        var arr = [[AttData]]()
        
        for i in 0...(arrAttCount ?? 0)-1{
            let filteredArr = self.attData?.att![i].d?.filter({$0.tg == "p"})
            print("filteredArr parent \(String(describing: filteredArr))")
            if filteredArr?.count ?? 0 > 0{
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
        }
    }
    
    func getTblViewHeight(){
        var totalCount = noOfSecrions
        totalCount += noOfAttributes + 1 //1 for headerview
        
        if noOfSecrions > 0{
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
        self.is201Received = false
        self.is201Received = false
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
            view.backgroundColor = .clear
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
                return arrData[section]["Tag"]?[0].count ?? 0//Int(10)
            }else{
                return 0
            }
        }
        return noOfAttributes//Int(10)
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
//        cell.textLabel?.text = "\(indexPath.row)"
        if self.arrChildDevices?.count ?? 0 > indexPath.section{
            cell.setAttData(data: (arrData[indexPath.section]["Tag"]?[0])!,index: indexPath.row)
        }else if arrParentData.count > 0{
            cell.setAttData(data: (arrParentData[0]["Tag"]?[0])!,index: indexPath.row)
        }else{
            if let data = self.attData{
                cell.setData(model: data,index: indexPath.item)
            }
        }

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}



