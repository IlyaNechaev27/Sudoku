//
//  AlertController.swift
//  Sudoku
//
//  Created by Илья Нечаев on 22.12.2021.
//

import UIKit

extension UIAlertController {
    
    static func createAlertController(withTitle title: String,and message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        return alert
    }
    
}

