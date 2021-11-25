import Foundation

enum Difficulty: Double {
    case Kid = 0.2
    case Easy = 0.3
    case Medium = 0.4
    case Hard = 0.5
    case Impossible = 0.6
}

class Sudoku {
    private var size: Int
    private var sideLen: Int
    private var puzzle = [[Int]]()
    private var currentAnswer = [[Int]]()
    private let rate: Double
    
    init(size: Int, rate: Difficulty) {
        self.size = size
        self.sideLen = size * size
        self.rate = rate.rawValue
        self.puzzle = generatePuzzle()
        self.currentAnswer = solve()
    }
    
    func getPuzzle() -> [[Int]] {
        puzzle
    }
    
    func getClue(x: Int, y: Int) {
        puzzle[x][y] = currentAnswer[x][y]
    }
    
    func isEnd() -> Bool {
        if let _ = findEmptyPosition(puzzle: puzzle) {
            return false
        }
        return true
    }
    
    private func sudokuRule(r: Int, c: Int) -> Int {
        (size * (r % size) + r / size + c) % (size * size)
    }
    
    private func shuffleArray(from a: Int, to b: Int) -> [Int] {
        let range = a..<b
        let array = Array(range)
        
        return array.shuffled()
    }
    
    private func generatePuzzle() -> [[Int]] {
        var rows: [Int] = []
        for g in shuffleArray(from: 0, to: size) {
            for r in shuffleArray(from: 0, to: size) {
                rows.append(size * g + r)
            }
        }
        
        var cols: [Int] = []
        for g in shuffleArray(from: 0, to: size) {
            for c in shuffleArray(from: 0, to: size) {
                cols.append(size * g + c)
            }
        }
        
        let nums = shuffleArray(from: 1, to: size * size + 1)
        
        var board: [[Int]] = []
        
        for r in rows {
            var row: [Int] = []
            for c in cols {
                row.append(nums[sudokuRule(r: r, c: c)])
            }
            board.append(row)
        }
        
        var emptyCount = 0.0
        
        while emptyCount / pow(Double(size), 4) <= rate {
            let x = Int.random(in: 0..<size * size)
            let y = Int.random(in: 0..<size * size)
            
            if board[x][y] != 0 {
                board[x][y] = 0
                emptyCount += 1
            }
        }
        
        return board
    }
    
    func makeMove(x: Int, y: Int, value: Int) -> Bool {
        let goodMove = checkMove(x: x, y: y, value: value)
        puzzle[x][y] = value
        if goodMove, puzzle[x][y] != currentAnswer[x][y] {
            currentAnswer = solve()
        }
        return goodMove
    }
    
    func print() {
        for i in puzzle {
            Swift.print(i)
        }
    }

    func solveAll() {
        puzzle = solve()
    }

    func clearCell(x: Int, y: Int) {
        puzzle[x][y] = 0
    }
    
    private func solve() -> [[Int]] {
        var tmp = [[Int]](puzzle)
        return solveInner(_puzzle: &tmp)
    }
    
    private func solveInner(_puzzle: inout [[Int]]) -> [[Int]] {
        guard let emptyPos = findEmptyPosition(puzzle: _puzzle) else {
            return _puzzle
        }
        let (x, y) = emptyPos
        var possibleValues = findPossibleValues(puzzle: _puzzle, x: x, y: y)
        possibleValues.shuffle()
        
        for possibleValue in possibleValues {
            _puzzle[x][y] = possibleValue
            let result = solveInner(_puzzle: &_puzzle)
            if result.count != 1 {
                return result
            }
            _puzzle[x][y] = 0
        }
        return [[]]
    }
    
    private func checkMove(x: Int, y: Int, value: Int) -> Bool {
        if puzzle[x][y] != 0 {
            return true
        }
        return checkRow(puzzle: puzzle, x: x, value: value) &&
            checkCol(puzzle: puzzle, y: y, values: value) &&
            checkBox(puzzle: puzzle, x: x, y: y, value: value)
    }
    
    private func checkRow(puzzle: [[Int]], x: Int, value: Int) -> Bool {
        !getRow(puzzle: puzzle, x: x).contains(value)
    }
    
    private func checkCol(puzzle: [[Int]], y: Int, values: Int) -> Bool {
        !getCol(puzzle: puzzle, y: y).contains(values)
    }
    
    private func checkBox(puzzle: [[Int]], x: Int, y: Int, value: Int) -> Bool {
        !getBlock(puzzle: puzzle, x: x, y: y).contains(value)
    }
    
    private func getRow(puzzle: [[Int]], x: Int) -> [Int] {
        puzzle[x]
    }
    
    private func getCol(puzzle: [[Int]], y: Int) -> [Int] {
        var result = [Int]()
        for row in puzzle {
            result.append(row[y])
        }
        return result
    }
    
    private func getBlock(puzzle: [[Int]], x: Int, y: Int) -> [Int] {
        var result = [Int]()
        
        let startX = x - x % size
        let startY = y - y % size
        
        for i in 0..<size {
            for j in 0..<size {
                result.append(puzzle[startX + i][startY + j])
            }
        }
        
        return result
    }
    
    private func findPossibleValues(puzzle: [[Int]], x: Int, y: Int) -> [Int] {
        var possible = Set(1..<sideLen + 1)
        possible = possible.filter { !getRow(puzzle: puzzle, x: x).contains($0) }
        possible = possible.filter { !getCol(puzzle: puzzle, y: y).contains($0) }
        possible = possible.filter { !getBlock(puzzle: puzzle, x: x, y: y).contains($0) }
        
        return Array(possible).shuffled()
    }
    
    private func findEmptyPosition(puzzle: [[Int]]) -> (Int, Int)? {
        for (x, row) in puzzle.enumerated() {
            for (y, v) in row.enumerated() {
                if v == 0 {
                    return (x, y)
                }
            }
        }
        return nil
    }
}
