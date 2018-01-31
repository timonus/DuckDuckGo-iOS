//
//  UIAlertControllerExtension.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 31/01/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    func addAction(_ title: String, handler: @escaping () -> Void) {
        addAction(UIAlertAction(title: title, style: .default, handler: { (action) in
            handler()
        }))
    }
    
    func addCancelAction() {
        addAction(UIAlertAction(title: UserText.actionCancel, style: .cancel))
    }
    
}
