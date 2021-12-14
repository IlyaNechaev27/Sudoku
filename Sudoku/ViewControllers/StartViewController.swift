//
//  ViewController.swift
//  Sudoku
//
//  Created by Илья Нечаев on 25.11.2021.
//

import UIKit

class StartViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var startStackView: UIStackView!
    @IBOutlet weak var difficultyStackView: UIStackView!
    
    @IBOutlet weak var kidButton: UIButton!
    @IBOutlet weak var easyButton: UIButton!
    @IBOutlet weak var mediumButton: UIButton!
    @IBOutlet weak var hardButton: UIButton!
    @IBOutlet weak var impossibleButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationButton()
        startStackView.isHidden = false
        difficultyStackView.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let puzzleVC = segue.destination as? PuzzleViewController else { return }
        puzzleVC.sudoku = Sudoku(rate: sender as! Difficulty)
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
    
    @IBAction func backButtonPressed(_ sender: Any) {
        difficultyStackView.isHidden.toggle()
        startStackView.isHidden.toggle()
        hideNavigationButton()
    }
    
    @IBAction func newGame(_ sender: UIButton) {
        showNavigationButton()
        startStackView.isHidden.toggle()
        difficultyStackView.isHidden.toggle()
    }
    
    @IBAction func loadGame(_ sender: UIButton) {
    }
    
    private func hideNavigationButton() {
        backButton.isEnabled = false
        backButton.tintColor = UIColor(hexString: "5b92cb")
    }
    
    private func showNavigationButton() {
        backButton.isEnabled = true
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
