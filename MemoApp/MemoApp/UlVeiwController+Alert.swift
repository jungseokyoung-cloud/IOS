//
//  UlVeiwController+Alert.swift
//  MemoApp
//
//  Created by jung on 2021/07/06.
//

import UIKit

extension UIViewController {
    func alert(title : String = "Alert", message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        
        let okAction = UIAlertAction(title: "Confirm", style: .default, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
}
