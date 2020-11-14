//
//  ButtonCell.swift
//  SignalReborn
//
//  Created by Amy While on 23/09/2020.
//  Copyright © 2020 Amy While. All rights reserved.
//

import UIKit

class ButtonCell: UITableViewCell {
    
    
    @IBOutlet weak var control: UIControl!
    @IBOutlet weak var label: UILabel!
    
    var notificationName = ""
    var buttonName = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setup() {
        label.text = buttonName
        control.addTarget(self, action: #selector(pressed), for: .touchUpInside)
    }
    
    @objc func pressed() {
        if !notificationName.isEmpty {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: notificationName), object: nil)
        }
    }
}
