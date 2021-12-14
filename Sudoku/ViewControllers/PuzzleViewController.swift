//
//  PuzzleViewController.swift
//  Sudoku
//
//  Created by Илья Нечаев on 13.12.2021.
//

import UIKit

class PuzzleViewController: UIViewController {
    var sudoku: Sudoku!
    
    @IBOutlet weak var puzzleView: SudokuView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        puzzleView.sudoku = sudoku
    }
}
