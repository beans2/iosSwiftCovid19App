//
//  ActivityIndicator+Expend.swift
//  Covid19App
//
//  Created by Mac Mini on 2021/03/05.
//

import Foundation
import UIKit
extension UIActivityIndicatorView{
    func activityStart(){
        self.isHidden = false
        self.startAnimating()
    }
    
    func activityStop(){
        self.stopAnimating()
        self.isHidden = true
    }
}
