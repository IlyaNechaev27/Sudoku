//
//  PuzzleViewController.swift
//  Sudoku
//
//  Created by Илья Нечаев on 13.12.2021.
//

import CoreData
import UIKit

class PuzzleViewController: UIViewController {
    var sudoku: Sudoku!
    var isPencilOn = false
    var timer = Timer()
    var countForTimer = 0
    var timerCounting = true
    var clueCount = 3
    
    // Поле судоки
    @IBOutlet var puzzleView: SudokuView!
    
    // Таймер
    @IBOutlet var timerLabel: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        StorageManager.sudokuModel = sudoku
        
        timerLabel.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Arial", size: 20)!], for: UIControl.State.normal)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
        navigationItem.setHidesBackButton(true, animated: true)
        
        isPencilOn = false
        puzzleView.sudoku = sudoku
    }
    
    @objc func timerCounter() {
        countForTimer = countForTimer + 1
        let time = secondsToHoursMinutesSeconds(seconds: countForTimer)
        let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
        timerLabel.title = timeString
    }
    
    func secondsToHoursMinutesSeconds(seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func makeTimeString(hours: Int, minutes: Int, seconds: Int) -> String {
        var timeString = ""
        timeString += String(format: "%02d", hours)
        timeString += " : "
        timeString += String(format: "%02d", minutes)
        timeString += " : "
        timeString += String(format: "%02d", seconds)
        return timeString
    }
    
    func refresh() {
        puzzleView.setNeedsDisplay()
    }
    
    @IBAction func keypad(_ sender: UIButton) {
        let row = puzzleView.selected.row
        let col = puzzleView.selected.col
        if row != -1, col != -1 {
            if isPencilOn == false {
                if !sudoku.numberIsFixedAt(row: row, col: col) && sudoku.getPuzzle()[row][col] == 0 {
                    sudoku.makeMove(x: row, y: col, value: sender.tag)
                    refresh()
                } else if !sudoku.numberIsFixedAt(row: row, col: col) || sudoku.getPuzzle()[row][col] == sender.tag {
                    sudoku.makeMove(x: row, y: col, value: sender.tag)
                    refresh()
                }
            } else {
                sudoku.pencilGrid(n: sender.tag, row: row, col: col)
                refresh()
            }
        }
        if sudoku.isEnd() {
            performSegue(withIdentifier: "showResult", sender: nil)
            StorageManager.sudokuModel = nil
        }
        
        StorageManager.sudokuModel = sudoku
    }
    
    @IBAction func deleteNumber(_ sender: UIButton) {
        
        let row = puzzleView.selected.row
        let col = puzzleView.selected.col
        
        if row == -1, col == -1 {
            presentAlert(withTitle: "Warning", message: "No puzzle cell selected")
            
        } else {
            
            if sudoku.getPuzzle()[row][col] != 0 {
                sudoku.userGrid(n: 0, row: row, col: col)
            }
            
            for i in 0 ... 9 {
                sudoku.pencilGridBlank(n: i, row: row, col: col)
            }
            refresh()
        }
    }
    
    @IBAction func pencilOn(_ sender: UIButton) {
        isPencilOn = !isPencilOn
        sender.isSelected = isPencilOn
    }
    
    @IBAction func mainMenu(_ sender: UIButton) {
        // UIAlertController
        let alert = UIAlertController(title: "MENU", message: "", preferredStyle: .alert)
        
        // Clear Conflicts
        alert.addAction(UIAlertAction(title: NSLocalizedString("Clear Conflicts", comment: "Default action"), style: .default, handler: { _ in
            self.sudoku.clearConflicts()
            self.refresh()
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Solve all", comment: "Default action"), style: .default, handler: { _ in
            self.performSegue(withIdentifier: "showResult", sender: nil)
        }))
        
        // Clear all
        alert.addAction(UIAlertAction(title: NSLocalizedString("Clear All", comment: ""), style: .default, handler: { _ in
            self.sudoku.clearUserPuzzle()
            self.sudoku.clearPencilPuzzle()
            self.refresh()
        }))
        
        // Get clue
        alert.addAction(UIAlertAction(title: NSLocalizedString("Get Clue", comment: ""), style: .default, handler: { _ in
            let row = self.puzzleView.selected.row
            let col = self.puzzleView.selected.col
            if row == -1, col == -1 {
                self.presentAlert(withTitle: "Warning", message: "No puzzle cell selected")
            } else {
                
                if self.clueCount != 0 {
                    self.clueCount -= 1
                    let row = self.puzzleView.selected.row
                    let col = self.puzzleView.selected.col
                    self.sudoku.getClue(x: row, y: col)
                    self.refresh()
                } else {
                    let clueAlert = UIAlertController(title: "You have no more clues left", message: "", preferredStyle: .alert)
                    clueAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(clueAlert, animated: true)
                }
            }
        }))
        
        // Cancel action
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default action"), style: .default, handler: { _ in
        }))
        
        // Present Alert
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func leavePuzzle(_ sender: Any) {
        // UIAlertController
        let alert = UIAlertController(
            title: "Leaving Current Game",
            message: "Are you sure you want to abandon?",
            preferredStyle: .alert
        )
        
        // Alert action
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("OK", comment: "Default action"),
                style: .default,
                handler: { _ in
                    self.sudoku.clearUserPuzzle()
                    self.navigationController?.popViewController(animated: true)
                }
            )
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default action"), style: .default, handler: { _ in
        }))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: Prepare for segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let resultVC = segue.destination as? ResultViewController else { return }
        resultVC.timer = timerLabel.title
        resultVC.difficulty = sudoku.difficulty
    }
}

extension PuzzleViewController {
    
    func presentAlert(withTitle title: String, message : String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { action in
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
