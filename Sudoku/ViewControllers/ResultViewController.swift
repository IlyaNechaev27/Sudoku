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
    @IBOutlet weak var gifView: UIImageView!
    
    @IBOutlet weak var textLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true);
        textLabel.text = "You have solved \(difficulty!) Sudoku in \(timer!)"
        gifView.loadGif(name: "finish")
    }
    @IBAction func dismis(_ sender: Any) {
        
        self.navigationController?.popToRootViewController(animated: true)


    }
    
}
