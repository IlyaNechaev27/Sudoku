//
//  ResultViewController.swift
//  Sudoku
//
//  Created by Илья Нечаев on 15.12.2021.
//

import UIKit

class ResultViewController: UIViewController {
    var timer: String!
    var difficulty: Difficulty!
    @IBOutlet var gifView: UIImageView!

    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setHidesBackButton(true, animated: true)
        difficultyLabel.text = "\(difficulty!) Sudoku"
        timerLabel.text = timer
        gifView.loadGif(name: "finish")
    }

    @IBAction func dismis(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
}
