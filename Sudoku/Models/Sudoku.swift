import Foundation


enum Difficulty: Double, Decodable {
    case Kid = 0.2
    case Easy = 0.3
    case Medium = 0.4
    case Hard = 0.5
    case Impossible = 0.6
}

public class Sudoku: NSObject, NSCoding {
    public func encode(with coder: NSCoder) {
        coder.encode(difficulty.rawValue, forKey: "dif")
        coder.encode(pencilPuzzle, forKey: "pen")
        coder.encode(size, forKey: "size")
        coder.encode(sideLen, forKey: "side")
        coder.encode(puzzle, forKey: "puzzle")
        coder.encode(currentAnswer, forKey: "current")
        coder.encode(rate, forKey: "rate")
        coder.encode(startPuzzle, forKey: "start")
    }
    
    public required init?(coder: NSCoder) {
        difficulty = coder.decodeObject(forKey: "dif") as? Difficulty ?? .Kid
        pencilPuzzle = coder.decodeObject(forKey: "pen") as? [[[Bool]]] ?? [[[]]]
        size = coder.decodeObject(forKey: "size") as? Int ?? 3
        sideLen = coder.decodeObject(forKey: "side") as? Int ?? 9
        puzzle = coder.decodeObject(forKey: "puzzle") as? [[Int]] ?? [[]]
        currentAnswer = coder.decodeObject(forKey: "current") as? [[Int]] ?? [[]]
        rate = coder.decodeObject(forKey: "rate") as? Double ?? 0.5
        startPuzzle = coder.decodeObject(forKey: "start") as? [[Int]] ?? [[]]
    }
    
    var difficulty: Difficulty
    
    private var pencilPuzzle = [[[Bool]]](repeating: [[Bool]](repeating: [Bool](repeating: false, count: 10), count: 9), count: 9)
    private var size = 3
    private var sideLen = 9
    private var puzzle = [[Int]]()
    private var currentAnswer = [[Int]]()
    private let rate: Double
    private var startPuzzle = [[Int]]()
    
    init(rate: Difficulty) {
        self.difficulty = rate
        self.rate = rate.rawValue
        super.init()
        self.puzzle = generatePuzzle()
        self.currentAnswer = solve()
        makeCopy()
    }
    
    func isConflictingEntryAt(row: Int, col: Int) -> Bool {
        puzzle[row][col] == currentAnswer[row][col] ? false : true
    }
    func setPencilAt(row: Int, col: Int) -> Bool {
        for n in 0...8 {
            if pencilPuzzle[row][col][n] == true {
                return true
            }
        }
        return false
    }
    
    func printResult() {
        print(currentAnswer)
    }
    func isSetPencil(n: Int, row: Int, col: Int) -> Bool {
        pencilPuzzle[row][col][n]
    }
    
    // setter - reverse
    func pencilGrid(n: Int, row: Int, col: Int) {
        pencilPuzzle[row][col][n] = !pencilPuzzle[row][col][n]
    }
    
    // setter - blank
    func pencilGridBlank(n: Int, row: Int, col: Int) {
        pencilPuzzle[row][col][n] = false
    }
    
    func clearPencilPuzzle() {
        pencilPuzzle = [[[Bool]]] (repeating: [[Bool]] (repeating: [Bool] (repeating: false, count: 10), count: 9), count: 9)
    }
    
    func numberIsFixedAt(row: Int, col: Int) -> Bool {
        if startPuzzle[row][col] != 0 {
            return true
        } else {
            return false
        }
    }
    
    func clearUserPuzzle() {
        puzzle = startPuzzle
    }
    
    // REQUIRED METHOD: Number stored at given row and column, with 0 indicating an empty cell or cell with penciled in values
    func numberAt(row : Int, col : Int) -> Int {
        if startPuzzle[row][col] != 0 {
            return startPuzzle[row][col]
        } else {
            return puzzle[row][col]
        }
    }
    
    // setter
    func userGrid(n: Int, row: Int, col: Int) {
        puzzle[row][col] = n
    }
    
    // Is the piece a user piece
    func userEntry(row: Int, col: Int) -> Int {
        return puzzle[row][col]
    }
    
    func getPuzzle() -> [[Int]]{
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
    
    private func makeCopy() {
        startPuzzle = puzzle
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
                rows.append(size*g + r)
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
    
    func clearConflicts() {
        for row in 0...8 {
            for col in 0...8 {
                if isConflictingEntryAt(row: row, col: col) {
                    puzzle[row][col] = 0
                }
            }
        }
    }
    
    func makeMove(x: Int, y: Int, value: Int) {
        puzzle[x][y] = value
    }
    
    func solveAll() {
        puzzle = solve()
    }
    
    func clearCell(x: Int, y: Int) {
        puzzle[x][y] = 0
    }
    
    private func solve() -> [[Int]]{
        var tmp = [[Int]](puzzle)
        return solveInner(_puzzle: &tmp)
    }
    
    private func solveInner( _puzzle: inout [[Int]]) -> [[Int]] {
        guard let emptyPos = findEmptyPosition(puzzle: _puzzle) else {
            return _puzzle
        }
        let (x,y) = emptyPos
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
        checkRow(puzzle: puzzle, x: x, value: value) &&
        checkCol(puzzle: puzzle, y: y, values: value) &&
        checkBox(puzzle: puzzle, x: x, y: y, value: value)
    }
    
    private func checkRow(puzzle: [[Int]], x: Int, value: Int) -> Bool{
        getRow(puzzle: puzzle, x: x).contains(value)
    }
    
    private func checkCol(puzzle: [[Int]], y: Int, values: Int) -> Bool {
        getCol(puzzle: puzzle, y: y).contains(values)
    }
    
    private func checkBox(puzzle: [[Int]], x: Int, y: Int, value: Int) -> Bool{
        getBlock(puzzle: puzzle, x: x, y: y).contains(value)
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
        possible = possible.filter({ !getRow(puzzle: puzzle, x: x).contains($0)})
        possible = possible.filter({ !getCol(puzzle: puzzle, y: y).contains($0)})
        possible = possible.filter({ !getBlock(puzzle: puzzle, x: x, y: y).contains($0)})
        
        return Array(possible).shuffled()
    }
    
    private func findEmptyPosition(puzzle: [[Int]]) -> (Int, Int)? {
        for (x, row) in puzzle.enumerated() {
            for (y, v) in row.enumerated() {
                if v == 0 {
                    return (x,y)
                }
            }
        }
        return nil
    }
}
