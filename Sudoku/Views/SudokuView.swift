
//  SudokuView.swift
//  Sudoku
//
//  Created by Илья Нечаев on 14.12.2021.
//

import UIKit

class SudokuView: UIView {
    var sudoku: Sudoku!
    /// Текущая выделенная ячейка в головоломке
    /// (-1 -> ячейка не выделена)
    var selected = (row: -1, col: -1)
    
    /// Позволяет пользователю «выбрать» незафиксированную ячейку в сетке головоломки.
    @IBAction func handleTap(_ sender: UIGestureRecognizer) {
        let tapPoint = sender.location(in: self)
        let gridSize = (bounds.width < bounds.height) ? bounds.width : bounds.height
        let gridOrigin = CGPoint(x: (bounds.width - gridSize)/2, y: (bounds.height - gridSize)/2)
        let d = gridSize/9
        let col = Int((tapPoint.x - gridOrigin.x)/d)
        let row = Int((tapPoint.y - gridOrigin.y)/d)
        
        if col >= 0, col < 9, row >= 0, row <= 9 {
            // если внутри пазла
            if !sudoku.numberIsFixedAt(row: row, col: col) {
                // если значение не зафиксировано
                if row != selected.row || col != selected.col {
                    // если не уже выбранная ячейка
                    selected.row = row
                    selected.col = col
                    setNeedsDisplay()
                    // запрос на перерисовку PuzzleView
                }
            }
        }
    }
    
    func fontSizeFor(_ string: NSString, fontName: String, targetSize: CGSize) -> CGFloat {
        let testFontSize: CGFloat = 32
        let font = UIFont(name: fontName, size: testFontSize)
        let attr = [NSAttributedString.Key.font: font!]
        let strSize = string.size(withAttributes: attr)
        return testFontSize*min(targetSize.width/strSize.width, targetSize.height/strSize.height)
    }
    
    /// Рисование доски судоку. Текущее состояние головоломки хранится в свойстве "sudoku"
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        /*Находим самый большой квадрат в границах обзора и используем его для определения
    параметров сетки.
         */
        let gridSize = bounds.width < bounds.height ? bounds.width : bounds.height
        let gridOrigin = CGPoint(x: (bounds.width - gridSize)/2, y: (bounds.height - gridSize)/2)
        let delta = gridSize/3
        let d = delta/3
        
        // Заполняем выбранную ячейку (только одну).
        if selected.row >= 0 && selected.col >= 0 {
            UIColor(hexString: "786FF5").setFill()
            let x = gridOrigin.x + CGFloat(selected.col)*d
            let y = gridOrigin.y + CGFloat(selected.row)*d
            context?.fill(CGRect(x: x, y: y, width: d, height: d))
        }
        
        // Обводка внешнего прямоугольника головоломки rectangle
        context?.setLineWidth(6)
        UIColor(hexString: "786FF5").setStroke()
        context?.stroke(CGRect(x: gridOrigin.x, y: gridOrigin.y, width: gridSize, height: gridSize))
        
        
        // Обводка основных линий сетки.
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
        
        // Обводка второстепенных линий сетки.
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
        
        // Получение / вычисление информации об атрибуте шрифта.
        let fontName = "Helvetica"
        let boldFontName = "Helvetica-Bold"
        let pencilFontName = "Helvetica-Light"
        
        let fontSize = fontSizeFor("0", fontName: boldFontName, targetSize: CGSize(width: d, height: d))
        
        let boldFont = UIFont(name: boldFontName, size: fontSize)
        let font = UIFont(name: fontName, size: fontSize)
        let pencilFont = UIFont(name: pencilFontName, size: fontSize/3)
        
        let fixedAttributes = [NSAttributedString.Key.font: boldFont!, NSAttributedString.Key.foregroundColor: UIColor.black]
        let userAttributes = [NSAttributedString.Key.font: font!, NSAttributedString.Key.foregroundColor: UIColor.blue]
        let conflictAttributes = [NSAttributedString.Key.font: font!, NSAttributedString.Key.foregroundColor: UIColor.red]
        let pencilAttributes = [NSAttributedString.Key.font: pencilFont!, NSAttributedString.Key.foregroundColor: UIColor.black]
        
        // Заполнение пазла цифрами
        for row in 0 ..< 9 {
            for col in 0 ..< 9 {
                var number: Int
                if sudoku.userEntry(row: row, col: col) != 0 {
                    number = sudoku.userEntry(row: row, col: col)
                } else {
                    number = sudoku.numberAt(row: row, col: col)
                }
                if number > 0 {
                    var attributes: [NSAttributedString.Key: NSObject]?
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
                } else if sudoku.setPencilAt(row: row, col: col) {
                    let s = d/3
                    for n in 1 ... 9 {
                        if sudoku.isSetPencil(n: n, row: row, col: col) {
                            let r = (n - 1)/3
                            let c = (n - 1) % 3
                            let text: NSString = "\(n)" as NSString
                            let textSize = text.size(withAttributes: pencilAttributes)
                            let x = gridOrigin.x + CGFloat(col)*d + CGFloat(c)*s + 0.5*(s - textSize.width)
                            let y = gridOrigin.y + CGFloat(row)*d + CGFloat(r)*s + 0.5*(s - textSize.height)
                            let textRect = CGRect(x: x, y: y, width: textSize.width, height: textSize.height)
                            text.draw(in: textRect, withAttributes: pencilAttributes)
                        }
                    }
                }
            }
        }
    }
}
