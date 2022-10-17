//
//  ViewController.swift
//  DemoIOTConnectSDK_Swift
//
//  Created by rushabh.patel on 10/08/21.
//

import UIKit
import IoTConnect

class ViewController: UIViewController {

    @IBOutlet var btnStatus : UIButton!
    @IBOutlet var btnConnect : UIButton!
    @IBOutlet var txtCPID,txtUniqueID : UITextField!
    @IBOutlet var tblProperty : UITableView!
    @IBOutlet var heightTableConstraint : NSLayoutConstraint!
    @IBOutlet var txtView : UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    @IBAction private func clickActions(sender: AnyObject) {
        if sender.isEqual(btnConnect) {
            connectSDK()
        }
    }
    func connectSDK() {

    //This code works for certificate authentication
        
/*
        var sdkOptions = SDKClientOption()
        
        //SSL Certificates with password
        sdkOptions.SSL.Certificate = Bundle.main.path(forResource: "device.pfx", ofType: nil)
        sdkOptions.SSL.Password = "1234"
        
        //Offline Storage Configuration
        sdkOptions.OfflineStorage.AvailSpaceInMb = 0
        sdkOptions.OfflineStorage.FileCount = 10
        
        //For Developer
        sdkOptions.discoveryUrl = "https://discovery.iotconnect.io"
        sdkOptions.debug = true
        
        //For SSL Enable Device Connection
        let objConfig = IoTConnectConfig(cpId: "nine", uniqueId: "iosss01", env: "QA", sdkOptions: sdkOptions)
 
 */
        
        //This code works for token base authentication

        
        let objConfig = IoTConnectConfig(cpId: "{replace-with-your-id}",
                                                 uniqueId: "{replace-with-your-id}",
                                                 env: .QA,
                                                 mqttConnectionType: .userCredntialAuthentication,
                                                 sdkOptions: nil)
        
        SDKClient.shared.initialize(config: objConfig)
        
        SDKClient.shared.getDeviceCallBack { (message) in
            print("message: ", message as Any)
        }
        
        SDKClient.shared.getTwinUpdateCallBack { (twinMessage) in
            print("twinMessage: ", twinMessage as Any)
        }
        
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
        if section == 0 {
            headerView.lblSectionTitle.text = "Section 1"
        } else {
            headerView.lblSectionTitle.text = "Section 2"
        }
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
        return Int(10)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : PropertyCell = tableView.dequeueReusableCell(withIdentifier: "PropertyCell", for: indexPath) as! PropertyCell
        cell.selectionStyle = .none
        cell.titleLabel.text = "Rushabh"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}



