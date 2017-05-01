//
//  LoginView.swift
//  IOSLab5
//
//  Created by Thitiwat on 4/26/2560 BE.
//  Copyright © 2560 Thitiwat. All rights reserved.
//

import UIKit

class LoginView: UIView {

    @IBOutlet weak var googleBtn: UIButton!
    @IBOutlet weak var facebookBtn: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = true
        googleBtn.clipsToBounds = true
        facebookBtn.clipsToBounds = true
        
        googleBtn.layer.cornerRadius = 15
        facebookBtn.layer.cornerRadius = 15
        
    }
}
