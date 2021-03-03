//
//  AlertPresenter.swift
//  MovieBox
//
//  Created by Димас on 03.03.2021.
//

import Foundation
import UIKit

class AlertPresenter {
    
    static func presentAlertController(_ sender: UIViewController, title: String, message: String) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        sender.present(alert, animated: true, completion: nil)
    }
}
