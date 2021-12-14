//
//  SudokuView.swift
//  Sudoku
//
//  Created by Илья Нечаев on 14.12.2021.
//

import UIKit



class SudokuView: UIView {
    var sudoku: Sudoku!
    var selected = (row : -1, col : -1)
    
    @IBAction func handleTap(_ sender: UIGestureRecognizer) {
        let tapPoint = sender.location(in: self)
        let gridSize =  (self.bounds.width < self.bounds.height) ? self.bounds.width : self.bounds.height
        let gridOrigin = CGPoint(x: (self.bounds.width - gridSize) / 2, y: (self.bounds.height - gridSize) / 2)
        let d = gridSize / 9
        let col = Int((tapPoint.x - gridOrigin.x) / d)
        let row = Int((tapPoint.y - gridOrigin.y) / d)
        
        if 0 <= col && col < 9 && 0 <= row && row <= 9 {
            if !sudoku.numberIsFixedAt(row: row, col: col) {
                if row != selected.row || col != selected.col {
                    selected.row = row
                    selected.col = col
                    self.setNeedsDisplay()

                }
            }
        }
    }
    
    func fontSizeFor(_ string : NSString, fontName : String, targetSize : CGSize) -> CGFloat {
        let testFontSize : CGFloat = 32
        let font = UIFont(name: fontName, size: testFontSize)
        let attr = [NSAttributedString.Key.font : font!]
        let strSize = string.size(withAttributes: attr)
        return testFontSize*min(targetSize.width/strSize.width, targetSize.height/strSize.height)
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        let gridSize = self.bounds.width < self.bounds.height ? self.bounds.width : self.bounds.height
        let gridOrigin = CGPoint(x: (self.bounds.width - gridSize)/2, y: (self.bounds.height - gridSize)/2)
        let delta = gridSize/3
        let d = delta/3
        
        
        
        //
        // Fill selected cell (is one is selected).
        //
        if selected.row >= 0 && selected.col >= 0 {
            UIColor(hexString: "5b92cb").setFill()
            let x = gridOrigin.x + CGFloat(selected.col)*d
            let y = gridOrigin.y + CGFloat(selected.row)*d
            context?.fill(CGRect(x: x, y: y, width: d, height: d))
        }
        
        //
        // Stroke outer puzzle rectangle
        //
        context?.setLineWidth(6)
        UIColor(hexString: "5b92cb").setStroke()
        context?.stroke(CGRect(x: gridOrigin.x, y: gridOrigin.y, width: gridSize, height: gridSize))
        
        
        //
        // Stroke major grid lines.
        //
        for i in 0 ..< 3 {
            let x = gridOrigin.x + CGFloat(i)*delta
            context?.move(to: CGPoint(x: x, y: gridOrigin.y))
            context?.addLine(to: CGPoint(x: x, y: gridOrigin.y + gridSize))
            context?.strokePath()
        }
        for i in 0 ..< 3 {
            let y = gridOrigin.y + CGFloat(i)*delta
            context?.move(to: CGPoint(x: gridOrigin.x, y: y))
            context?.addLine(to: CGPoint(x: gridOrigin.x + gridSize, y: y))
            context?.strokePath()
        }
        
        //
        // Stroke minor grid lines.
        //
        context?.setLineWidth(3)
        for i in 0 ..< 3 {
            for j in 0 ..< 3 {
                let x = gridOrigin.x + CGFloat(i)*delta + CGFloat(j)*d
                context?.move(to: CGPoint(x: x, y: gridOrigin.y))
                context?.addLine(to: CGPoint(x: x, y: gridOrigin.y + gridSize))
                let y = gridOrigin.y + CGFloat(i)*delta + CGFloat(j)*d
                context?.move(to: CGPoint(x: gridOrigin.x, y: y))
                context?.addLine(to: CGPoint(x: gridOrigin.x + gridSize, y: y))
                context?.strokePath()
            }
        }
        
        //
        // Fetch/compute font attribute information.
        //
        let fontName = "Helvetica"
        let boldFontName = "Helvetica-Bold"
//        let pencilFontName = "Helvetica-Light"
        
        let fontSize = fontSizeFor("0", fontName: boldFontName, targetSize: CGSize(width: d, height: d))
        
        let boldFont = UIFont(name: boldFontName, size: fontSize)
        let font = UIFont(name: fontName, size: fontSize)
//        let pencilFont = UIFont(name: pencilFontName, size: fontSize/3)
        
        let fixedAttributes = [NSAttributedString.Key.font : boldFont!, NSAttributedString.Key.foregroundColor : UIColor.black]
        let userAttributes = [NSAttributedString.Key.font : font!, NSAttributedString.Key.foregroundColor : UIColor.blue]
        let conflictAttributes = [NSAttributedString.Key.font : font!, NSAttributedString.Key.foregroundColor : UIColor.red]
        //        let pencilAttributes = [NSAttributedString.Key.font : pencilFont!, NSAttributedString.Key.foregroundColor : UIColor.black]
        
        //
        // Fill in puzzle numbers.
        //
        
        for row in 0..<9 {
            for col in 0..<9 {
                var number: Int
                if sudoku.userEntry(row: row, col: col) != 0 {
                    number = sudoku.userEntry(row: row, col: col)
                } else {
                    number = sudoku.numberAt(row: row, col: col )
                }
                if (number > 0) {
                    var attributes: [NSAttributedString.Key : NSObject]? = nil
                    if sudoku.numberIsFixedAt(row: row, col: col) {
                        attributes = fixedAttributes
                    } else if sudoku.isConflictingEntryAt(row: row, col: col) {
                        attributes = conflictAttributes
                    } else if sudoku.userEntry(row: row, col: col) != 0 {
                        attributes = userAttributes
                    }
                    let text = "\(number)" as NSString
                    let textSize = text.size(withAttributes: attributes)
                    let x = gridOrigin.x + CGFloat(col)*d + 0.5*(d - textSize.width)
                    let y = gridOrigin.y + CGFloat(row)*d + 0.5*(d - textSize.height)
                    let textRect = CGRect(x: x, y: y, width: textSize.width, height: textSize.height)
                    text.draw(in: textRect, withAttributes: attributes)
                }
            }
        }
    }
}
