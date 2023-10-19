//
//  PropertyCell.swift
//  DemoIOTConnectSDK_Swift
//
//  Created by rushabh.patel on 10/08/21.
//

import UIKit

class PropertyCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet weak var txtField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //set textfield placeholder data
    func setAttData(data:[AttD],index:Int){
        if index < data.count{
            let parentName = data[index].p
            let ln = data[index].ln
            self.txtField.placeholder = !(parentName?.isEmpty ?? true) ? "\(parentName ?? ""):\(ln ?? "")" : "\(ln ?? "")"
            self.txtField.text = data[index].value ?? ""
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
