//
//  DifficultyViewController.swift
//  Sudoku
//
//  Created by Илья Нечаев on 21.12.2021.
//

import UIKit

class DifficultyViewController: UIViewController {
    
    @IBOutlet weak var kidButton: UIButton!
    @IBOutlet weak var easyButton: UIButton!
    @IBOutlet weak var mediumButton: UIButton!
    @IBOutlet weak var hardButton: UIButton!
    @IBOutlet weak var impossibleButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView?.tintColor = UIColor(hexString: "5B92CB")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "BACK", style: UIBarButtonItem.Style.done, target: nil, action: nil)
    }
    
    @IBAction func difficultyButtonPressed(_ sender: UIButton) {
        switch sender {
        case kidButton:
            performSegue(withIdentifier: "toPuzzle", sender: Difficulty.Kid)
        case easyButton:
            performSegue(withIdentifier: "toPuzzle", sender: Difficulty.Easy)
        case mediumButton:
            performSegue(withIdentifier: "toPuzzle", sender: Difficulty.Medium)
        case hardButton:
            performSegue(withIdentifier: "toPuzzle", sender: Difficulty.Hard)
        case impossibleButton:
            performSegue(withIdentifier: "toPuzzle", sender: Difficulty.Impossible)
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let puzzleVC = segue.destination as? PuzzleViewController else { return }
        puzzleVC.sudoku = Sudoku(rate: sender as! Difficulty)
    }

}
