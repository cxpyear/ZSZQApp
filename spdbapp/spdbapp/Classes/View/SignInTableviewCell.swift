//
//  SignInTableviewCell.swift
//  spdbapp
//
//  Created by GBTouchG3 on 15/8/21.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit

class SignInTableviewCell: UITableViewCell {

//    @IBOutlet weak var lblSignInUserName: UILabel!
    @IBOutlet weak var lblSignInUserId: UILabel!
    @IBOutlet weak var btnSignIn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        btnSignIn.layer.cornerRadius = 8
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
