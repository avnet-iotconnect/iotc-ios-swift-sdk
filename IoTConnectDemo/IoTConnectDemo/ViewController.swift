//
//  ViewController.swift
//  DemoIOTConnectSDK_Swift
//
//  Created by rushabh.patel on 10/08/21.
//

import UIKit
import IoTConnect

public enum DeviceConnectionStatus{
    case connected
    case disconnected
}


class ViewController: UIViewController {

    @IBOutlet var btnStatus : UIButton!
    @IBOutlet var btnConnect : UIButton!
    @IBOutlet var txtCPID,txtUniqueID : UITextField!
    @IBOutlet var tblProperty : UITableView!
    @IBOutlet var heightTableConstraint : NSLayoutConstraint!
    @IBOutlet var txtView : UITextView!
    
    @IBOutlet weak var btnQA: UIButton!
    @IBOutlet weak var btnPOC: UIButton!
    @IBOutlet weak var btnAvnet: UIButton!
    @IBOutlet weak var btnDev: UIButton!
    @IBOutlet weak var tblviewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var btnGetTwins: UIButton!
    @IBOutlet weak var btnSendData: UIButton!
    
    private var btnConnectTitle = "CONNECT"
    private var btnDisConnectTitle = "DISCONNECT"
    private let tblViewRowheight = 44.0
    private var env:Environment = .AVNETPOC
    private var devivceStatus:DeviceConnectionStatus = .disconnected
   // private var noOfAttributes = 0
    private let radioController: RadioButtonController = RadioButtonController()
    private var dictAttributes:[[String:Any]]?
    private var attribute:[Att]?
    private var arrParsedDeviceData:[AttD]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        radioController.buttonsArray = [btnAvnet,btnQA,btnDev,btnPOC]
        radioController.defaultButton = btnAvnet
        
        //button Status Corner Radius
        btnStatus.layer.cornerRadius = 12.5

        //Register Table Header View
        let nib = UINib(nibName: "TableHeaderView", bundle: nil)
        tblProperty.register(nib, forHeaderFooterViewReuseIdentifier: "TableHeaderView")
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        //Add Underline textfield
        self.txtCPID.addUnderLine()
        self.txtUniqueID.addUnderLine()
        
        txtView.layer.cornerRadius = 10
        txtView.layer.borderWidth = 1
        txtView.layer.borderColor = UIColor.darkGray.cgColor
        
        heightTableConstraint.constant = (20*44) + 80
    }

    //MARK: - Custom Methods
    
    func connectSDK() {

    //This code works for certificate authentication

        if !txtCPID.text!.isEmpty && !txtUniqueID.text!.isEmpty{
            //This code works for token base authentication
            let objConfig = IoTConnectConfig(cpId: txtCPID.text?.replacingOccurrences(of: " ", with: "") ?? "",
                                             uniqueId: txtUniqueID.text?.replacingOccurrences(of: " ", with: "")  ?? "",
                                             env: env,
                                             mqttConnectionType: .userCredntialAuthentication,
                                             sdkOptions: nil)
            
            SDKClient.shared.initialize(config: objConfig)
            
            SDKClient.shared.getDeviceCallBack { (message) in
                print("message: ", message as Any)
                
                DispatchQueue.main.async {
                    self.txtView.text = "\(message ?? "")"
                    self.txtUniqueID.resignFirstResponder()
                    self.txtCPID.resignFirstResponder()
                }
                if let msg = message as? [String:Any]{
                    
                    if let msgData = msg["data"] as? [String:Any]{
                        if let cmdType = msgData["cmdType"]{
                            if cmdType as! String == "0x16"{
                                if let command = msgData["command"]{
                                    if command as! Bool == true{
                                        self.setConnectStatusUI()
                                    }else{
                                        SDKClient.shared.dispose()
                                        self.setDisconnectUI()
                                    }
                                    
                                }
                             
                            }
                        } else if msg["sdkStatus"] as? String == "connect"{
                            self.setConnectStatusUI()
                        }
                        else if let attData = msgData["att"] as? [[String:Any]]{
                            self.setConnectStatusUI()
                            self.manageAttributeResponse(response: attData)
                        }
                    }
                }
            }
            
            SDKClient.shared.getTwinUpdateCallBack { (twinMessage) in
                print("twinMessage: ", twinMessage as Any)
            }
        }else{
            if txtCPID.text!.isEmpty{
                presentAlert(title: "Please enter CPID value")
            }else{
                presentAlert(title: "Please enter unique ID value")
            }
        }
        
    }
    
    func manageAttributeResponse(response:[[String:Any]]){
        print("Attribute response \(response)")
        self.dictAttributes = response
        do {
            let json = try JSONSerialization.data(withJSONObject: response)
            let decoder = JSONDecoder()
            let decodedAttributes = try decoder.decode([Att].self, from: json)
            self.attribute = decodedAttributes
          //  let att = self.attribute?.d
            parseAttributeResponse()
            
            DispatchQueue.main.async {
                self.getTblViewHeight()
                self.enableMessageBtns()
            }
        } catch {
            print(error)
        }
        
    }
    
    func parseAttributeResponse(){
        print("parseAttributeResponse")
        var data = self.attribute
        var arrAttData = [AttD]()

        for i in 0...(data?.count ?? 0)-1{
            let d = data?[i].d
            let p = data?[i].p
            
            for j in 0...(d?.count ?? 0)-1{
                if arrAttData.count > 0{
                   // for k in 0...(data?[i].d?.count ?? 0)-1{
                        data?[i].d?[j].p = p
                        arrAttData.insert((data?[i].d?[j])!, at: arrAttData.count)
                  //  }
                }else{
                    data?[i].d?[j].p = p
                  //  arrAttData.append(data?[i].d)
                    arrAttData.append((data?[i].d?[j])!)
                }
            }
        }
        arrParsedDeviceData = arrAttData
        print("arrAttData \(arrAttData)")
        
        DispatchQueue.main.async{
            self.tblProperty.isHidden = false
            self.tblProperty.reloadData()
        }
    }
    
    func getTblViewHeight(){
        heightTableConstraint.constant =  Double(arrParsedDeviceData?.count ?? 0) * tblViewRowheight
        
        DispatchQueue.main.async {
            self.tblProperty.reloadData()
        }
    }
    
    func loadData(){
        var arrFinalData = [String:Any]()
        
        
        if arrParsedDeviceData?.count ?? 0 > 0{
            for i in 0...(arrParsedDeviceData?.count ?? 0) - 1{
                if arrParsedDeviceData?[i].p != nil ||
                    arrParsedDeviceData?[i].p?.isEmpty == false{
                    if arrFinalData[arrParsedDeviceData?[i].p ?? ""] == nil{
                        arrFinalData.updateValue(["\(arrParsedDeviceData?[i].ln ?? "")":arrParsedDeviceData?[i].value ?? ""], forKey:"\(arrParsedDeviceData?[i].p ?? "")")
                    }else{
                        let val = arrFinalData["\(arrParsedDeviceData?[i].p ?? "")"] as? [String:Any]
                        let newVal = ["\(arrParsedDeviceData?[i].ln ?? "")":arrParsedDeviceData?[i].value ?? ""] as? [String:Any]
                        
                        arrFinalData[(arrParsedDeviceData?[i].p)!] = val?.merging(newVal ?? [:], uniquingKeysWith: { current, _ in
                            return current
                        })
                    }
                }else{
                    arrFinalData[arrParsedDeviceData?[i].ln ?? ""] =  arrParsedDeviceData?[i].value
                   
                }
            }
        }
        
        let data=[[
            "uniqueId": txtUniqueID.text ?? "",
                    "time": now(),
                    "data":arrFinalData
                ]]
        SDKClient.shared.sendData(data: data)
    }
    
    //Presemt Alerrt View controller
    func presentAlert(title:String = "",msg:String = ""){
        DispatchQueue.main.async {
            let alertVC = UIAlertController (title: title, message: msg, preferredStyle: .alert)
            let okAction = UIAlertAction (title: "OK", style: .default)
            alertVC.addAction(okAction)
            self.present(alertVC, animated: true)
        }
    }
    
    func setConnectStatusUI(boolBtnEnable:Bool = false){
        DispatchQueue.main.async {
            self.devivceStatus = .connected
            self.btnConnect.setTitle(self.btnDisConnectTitle, for: .normal)
            self.btnStatus.backgroundColor = .green
           // self.lblStatus.text = statusText.connected.rawValue
            
            if boolBtnEnable{
                self.enableMessageBtns()
            }
        }
    }
    
    func setDisconnectUI(isRefresh:Bool = false){
        if !isRefresh{
            self.devivceStatus = .disconnected
            self.btnConnect.setTitle(self.btnConnectTitle, for: .normal)
            self.btnStatus.backgroundColor = .red
            self.arrParsedDeviceData = nil
            self.dictAttributes = nil
            self.attribute = nil
            self.disableMsgBtns()
        
            DispatchQueue.main.async {
                self.devivceStatus = .disconnected
                self.btnConnect.setTitle(self.btnConnectTitle, for: .normal)
                self.btnStatus.backgroundColor = .red
                self.tblProperty.isHidden = true
            }
        }
    }
    
    //Enable get twins and send data button
    func enableMessageBtns(){
        print("enableMessageBtns")
        manageBtnControl(btn: self.btnGetTwins, isEnable: true)
        manageBtnControl(btn: self.btnSendData, isEnable: true)
    }
    
    //Disable get twins and send data button
    func disableMsgBtns(){
        print("disableMsgBtns")
        manageBtnControl(btn: self.btnGetTwins, isEnable: false)
        manageBtnControl(btn: self.btnSendData, isEnable: false)
    }
    
    //Manage button color and button text control while enable or disable
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

    
    func now() -> String {
        return toString(fromDateTime: Date())
    }

//comvert date to desired foramat
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
    
    
//MARK: @IBAction
//    @IBAction private func clickActions(sender: AnyObject) {
//        if sender.isEqual(btnConnect) {
//            connectSDK()
//        }
//    }

    @IBAction func btnConnectTapped(_ sender: Any) {
        if self.devivceStatus == .disconnected{
            connectSDK()
        }else{
            SDKClient.shared.dispose()
        }
    }
    
    
    @IBAction func btnAvnetTapped(_ sender: UIButton) {
        env = .AVNETPOC
        radioController.buttonArrayUpdated(buttonSelected: sender)
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
    
    
    @IBAction func btnSendDataTapped(_ sender: Any) {
//        let data=[[
//                    "uniqueId": "AAA20",
//                    "time": now(),
//                    "data": ["Temp": "15"]
//                ]]
//        SDKClient.shared.sendData(data: data)
        self.loadData()
    }

    @IBAction func btnGetAllTwinsTapped(_ sender: Any) {
        
        
        
    }
    
    @IBAction func btnClearTapped(_ sender: Any) {
        self.txtView.text = ""
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
        return 40.0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableHeaderView") as! TableHeaderView
//        if section == 0 {
//            headerView.lblSectionTitle.text = "Section 1"
//        } else {
//            headerView.lblSectionTitle.text = "Section 2"
//        }
        headerView.lblSectionTitle.text = "TAG::p:\(self.txtUniqueID.text ?? "")"
        let view = UIView()
        headerView.frame.size.width = tableView.frame.size.width
        view.frame = headerView.frame
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        view.addSubview(headerView)
        return view
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrParsedDeviceData?.count ?? 0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tblViewRowheight
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : PropertyCell = tableView.dequeueReusableCell(withIdentifier: "PropertyCell", for: indexPath) as! PropertyCell
        cell.selectionStyle = .none
        if let data = arrParsedDeviceData{
            cell.setAttData(data: data, index: indexPath.row)
        }
      
       // cell.backgroundColor = .blue
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension ViewController:UITextFieldDelegate{

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var v : UIView = textField
        repeat { v = v.superview! } while !(v is UITableViewCell)
        let cell = v as! PropertyCell // or UITableViewCell or whatever
        let ip = self.tblProperty.indexPath(for:cell)!
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            //update the updated textfield value in model
            arrParsedDeviceData?[ip.row].value = updatedText
        }
        return true
    }
}



