//
//  StorageManager.swift
//  Sudoku
//
//  Created by Илья Нечаев on 22.12.2021.
//

import Foundation

/// StorageManager:
/// - сохраняет модель головоломки в памяти
/// - отслеживает изменение модели и записывает изменения в памяти
final class StorageManager {
    private enum SettingsKeys: String {
        case userModel
    }
    
    static var sudokuModel: Sudoku! {
        // getter
        get {
            guard let savedData = UserDefaults.standard.object(forKey: SettingsKeys.userModel.rawValue) as? Data,
                  let decodedModel = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedData) as? Sudoku else { return nil }
            return decodedModel
        }
        //setter
        set {
            let defaults = UserDefaults.standard
            let key = SettingsKeys.userModel.rawValue
            
            if let userModel = newValue {
                if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: userModel, requiringSecureCoding: false) {
                    print("value: \(userModel) was added to key \(key)")
                    defaults.set(savedData, forKey: key)
                } else {
                    defaults.removeObject(forKey: key)
                }
            }
        }
    }
}
