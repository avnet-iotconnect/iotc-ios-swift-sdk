//
//  ChildOperationVC.swift
//  IoTConnectDemo
//
//  Created by kirtan.vaghela on 21/08/23.
//

import UIKit
#if DEMOAWS
import IoTConnect2_AWS
#else
import IoTConnect2
#endif


class ChildOperationVC: UIViewController {
    
    //MARK: @IBOutlet
//    @IBOutlet weak var dropDown: DropDown!
    @IBOutlet weak var txtFieldUniqueID: UITextField!
    @IBOutlet weak var txtFieldDisplayName: UITextField!
    @IBOutlet weak var viewProgress: UIView!
    @IBOutlet weak var btnDropDown: UIButton!
    
    
    //MARK: Variable
    var tag = ""
    var tagArray = [String]()
    
    private var btnTagDropDown = DropDown()
    lazy var dropDown:DropDown = btnTagDropDown
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDropDown()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.txtFieldUniqueID.addUnderLine()
        self.txtFieldDisplayName.addUnderLine()
    }
    
    func setupDropDown(){
//        dropDown.arrowSize = 20
//        dropDown.optionArray = tagArray//["Option 1", "Option 2", "Option 3"]
//        dropDown.didSelect{(selectedText , index ,id) in
//            self.tag = selectedText
//        }
        
        DispatchQueue.main.async {
            self.btnDropDown.layer.borderColor = UIColor.black.cgColor
            self.btnDropDown.layer.borderWidth = 1.0
        }
        
        btnTagDropDown.dataSource = tagArray
        btnTagDropDown.selectionAction = { [weak self] (index,item) in
            self?.btnDropDown.setTitle(self?.tagArray[index], for: .normal)
            self?.tag = self?.tagArray[index] ?? ""
        }
        btnTagDropDown.anchorView = btnDropDown
        btnTagDropDown.bottomOffset = CGPoint(x: 0, y: btnDropDown.bounds.height+5)
    }
    
    func presentAlert(title:String = "",msg:String = ""){
        DispatchQueue.main.async {
            let alertVC = UIAlertController (title: title, message: msg, preferredStyle: .alert)
            let okAction = UIAlertAction (title: "OK", style: .default)
            alertVC.addAction(okAction)
            self.present(alertVC, animated: true)
        }
    }
    
    //MARK: @IBAction
    @IBAction func btnBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func createDecviceTapped(_ sender: Any) {
        if !(txtFieldUniqueID.text?.isEmpty ?? false) && !(txtFieldDisplayName.text?.isEmpty ?? false) &&
            tag != ""{
            DispatchQueue.main.async {
                self.viewProgress.isHidden = false
              
            }
            //Send data to SDK and handle response and show alert
            SDKClient.shared.createChildDevice(deviceId: txtFieldUniqueID.text ?? "", deviceTag:self.tag, displayName:  txtFieldDisplayName.text ?? ""  , createChildCallBack:{ (response) in
                DispatchQueue.main.async {
                    self.viewProgress.isHidden = true
                    self.txtFieldUniqueID.text = ""
                    self.txtFieldDisplayName.text = ""
                }
                if let dict = response as? [String:Any]{
                    let dictD = dict["d"] as? [String:Any]
                    let ec = dictD?["ec"] as? Int
                    if ec == 0{
                        self.presentAlert(title: "Child Device created successfully")
                    }else{
                        self.presentAlert(title: "Error")
                    }
                }else{
                    self.presentAlert(title: "\(response ?? "Error")")
                }
            })
        }else{
            presentAlert(title:"Please fill all the details")
        }
    }
    
    @IBAction func btnDropDownTapped(_ sender: Any) {
        self.btnTagDropDown.show()
    }
    
    
    @IBAction func deleteDeviceTapped(_ sender: Any) {
        if !txtFieldUniqueID.text!.isEmpty{
            DispatchQueue.main.async {
                self.viewProgress.isHidden = false
            }
            //Send data to SDK and handle response and show alert
            SDKClient.shared.deleteChildDevice(deviceId: txtFieldUniqueID.text ?? "") { response in
                DispatchQueue.main.async {
                    self.viewProgress.isHidden = true
                    self.txtFieldUniqueID.text = ""
                    self.txtFieldDisplayName.text = ""
                }
                if let dict = response as? [String:Any]{
                    let dictD = dict["d"] as? [String:Any]
                    let ec = dictD?["ec"] as? Int
                    if ec == 0{
                        self.presentAlert(title: "Child Device deleted successfully")
                    }else{
                        self.presentAlert(title: "Error")
                    }
                }else{
                    self.presentAlert(title: "\(response ?? "Error")")
                }
            }
        }else{
            presentAlert(title: "Please enter unique id")
        }
    }
    
}
