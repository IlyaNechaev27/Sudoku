//
//  ViewController.swift
//  Sudoku
//
//  Created by Илья Нечаев on 25.11.2021.
//

import UIKit

class StartViewController: UIViewController {
    @IBOutlet var gifView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gifView.loadGif(name: "load")
    }
    
    /// Загрузки игры из памяти
    /// Если сохранённой игры нету, то выводит alert
    /// - Parameter sender: <#sender description#>
    @IBAction func loadGame(_ sender: UIButton) {
        if StorageManager.sudokuModel == nil {
            let alert = UIAlertController(
                title: "Warning",
                message: "You have no unfinished game",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        } else {
            performSegue(withIdentifier: "toPuzzle", sender: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let puzzleVC = segue.destination as? PuzzleViewController else { return }
        puzzleVC.sudoku = StorageManager.sudokuModel
    }
}
