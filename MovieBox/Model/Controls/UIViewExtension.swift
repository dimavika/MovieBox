//
//  UIViewExtension.swift
//  MovieBox
//
//  Created by Димас on 28.02.2021.
//

import Foundation
import UIKit

extension UIView {
    
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}
