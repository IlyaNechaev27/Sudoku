import Foundation

/// Перечисление с уровнями сложности судоки,
/// где значения - отношение количества незаполненных полей к заполненным
enum Difficulty: Double, Decodable {
    case Kid = 0.2
    case Easy = 0.3
    case Medium = 0.4
    case Hard = 0.5
    case Impossible = 0.6
}

/// Модель cудоки
public class Sudoku: NSObject, NSCoding {
    /// Уровень сложности судоки
    private(set) var difficulty: Difficulty
    /// Время, за которое пользователь решает судоку
    private(set) var timer: Int
    /// Пазл для "пометок карандашом"
    private var pencilPuzzle = [[[Bool]]](repeating: [[Bool]](repeating: [Bool](repeating: false, count: 10), count: 9), count: 9)
    /// Размер судоки / 2
    private var size = 3
    /// Размер судоки
    private var sideLen = 9
    /// Пазл пользователя
    private var puzzle = [[Int]]()
    /// Решение пазла
    private var currentAnswer = [[Int]]()
    /// Числовое значение уровня сложности
    private let rate: Double
    /// Сгенерированное поле
    private var startPuzzle = [[Int]]()
    
    /// Инициализатор
    /// - Parameter rate: уровень сложности судоки
    init(rate: Difficulty) {
        timer = 0
        difficulty = rate
        self.rate = rate.rawValue
        super.init()
        puzzle = generatePuzzle()
        currentAnswer = solve()
        makeCopy()
    }

    /// Декодирование данных из памяти
    public required init?(coder: NSCoder) {
        timer = coder.decodeObject(forKey: "timer") as? Int ?? 0
        difficulty = coder.decodeObject(forKey: "dif") as? Difficulty ?? .Kid
        pencilPuzzle = coder.decodeObject(forKey: "pen") as? [[[Bool]]] ?? [[[]]]
        size = coder.decodeObject(forKey: "size") as? Int ?? 3
        sideLen = coder.decodeObject(forKey: "side") as? Int ?? 9
        puzzle = coder.decodeObject(forKey: "puzzle") as? [[Int]] ?? [[]]
        currentAnswer = coder.decodeObject(forKey: "current") as? [[Int]] ?? [[]]
        rate = coder.decodeObject(forKey: "rate") as? Double ?? 0.5
        startPuzzle = coder.decodeObject(forKey: "start") as? [[Int]] ?? [[]]
    }

    /// Кодирование данных для сохранения в памяти
    public func encode(with coder: NSCoder) {
        coder.encode(timer, forKey: "timer")
        coder.encode(difficulty.rawValue, forKey: "dif")
        coder.encode(pencilPuzzle, forKey: "pen")
        coder.encode(size, forKey: "size")
        coder.encode(sideLen, forKey: "side")
        coder.encode(puzzle, forKey: "puzzle")
        coder.encode(currentAnswer, forKey: "current")
        coder.encode(rate, forKey: "rate")
        coder.encode(startPuzzle, forKey: "start")
    }
    
    /// Конфликтует ли введённое пользователем значение с решением судоки
    /// - Parameters:
    ///   - row: строка
    ///   - col: столбец
    func isConflictingEntryAt(row: Int, col: Int) -> Bool {
        puzzle[row][col] == currentAnswer[row][col] ? false : true
    }
    
    /// Внесение пользователем карандашных значений ячейку
    /// - Parameters:
    ///   - row: строка
    ///   - col: столбец
    func setPencilAt(row: Int, col: Int) -> Bool {
        for n in 0...8 {
            if pencilPuzzle[row][col][n] == true {
                return true
            }
        }
        return false
    }
    
    /// Внесены ли пользователем значения карандашом в ячейку
    /// - Parameters:
    ///   - n: число
    ///   - row: строка
    ///   - col: столбец
    func isSetPencil(n: Int, row: Int, col: Int) -> Bool {
        pencilPuzzle[row][col][n]
    }
    
    /// reverse
    func pencilGrid(n: Int, row: Int, col: Int) {
        pencilPuzzle[row][col][n] = !pencilPuzzle[row][col][n]
    }
    
    /// blank
    func pencilGridBlank(n: Int, row: Int, col: Int) {
        pencilPuzzle[row][col][n] = false
    }
    
    /// очистить карандашные значения
    func clearPencilPuzzle() {
        pencilPuzzle = [[[Bool]]](repeating: [[Bool]](repeating: [Bool](repeating: false, count: 10), count: 9), count: 9)
    }
    
    /// Задано ли значение, зафиксированное стартовым пазлом
    /// - Parameters:
    ///   - row: строка
    ///   - col: столбец
    func numberIsFixedAt(row: Int, col: Int) -> Bool {
        if startPuzzle[row][col] != 0 {
            return true
        } else {
            return false
        }
    }
    
    /// Очистить все изменения пользователя
    func clearUserPuzzle() {
        puzzle = startPuzzle
    }
    
    /// Число, содержащееся в данной строке и столбце, где 0 означает пустую ячейку или ячейку с карандашными пометками
    /// - Parameters:
    ///   - row: строка
    ///   - col: столбец
    func numberAt(row: Int, col: Int) -> Int {
        if startPuzzle[row][col] != 0 {
            return startPuzzle[row][col]
        } else {
            return puzzle[row][col]
        }
    }
    
    /// setter
    func userGrid(n: Int, row: Int, col: Int) {
        puzzle[row][col] = n
    }
    
    /// Является ли элемент частью пользователя
    func userEntry(row: Int, col: Int) -> Int {
        return puzzle[row][col]
    }
    
    /// getter
    func getPuzzle() -> [[Int]] {
        puzzle
    }
    
    /// Получить подсказку
    func getClue(row: Int, col: Int) {
        puzzle[row][col] = currentAnswer[row][col]
    }
    
    /// Достигнут ли конец игры?
    func isEnd() -> Bool {
        puzzle == currentAnswer
    }
    
    /// Правила судоки
    private func sudokuRule(r: Int, c: Int) -> Int {
        (size * (r % size) + r / size + c) % (size * size)
    }
    
    /// Создание копии стартового пазла для бэктрекинга
    private func makeCopy() {
        startPuzzle = puzzle
    }
    
    /// shuffle заданного диапазона
    /// - Parameters:
    ///   - a: начал
    ///   - b: конец
    /// - Returns: shuffled array
    private func shuffleArray(from a: Int, to b: Int) -> [Int] {
        let range = a..<b
        let array = Array(range)
        
        return array.shuffled()
    }
    
    /// Создание стартового пазла
    /// - Returns: Стартовый пазл
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
    
    /// Очистка конфликтов
    func clearConflicts() {
        for row in 0...8 {
            for col in 0...8 {
                if isConflictingEntryAt(row: row, col: col) {
                    puzzle[row][col] = 0
                }
            }
        }
    }
    
    /// Внесение пользователем изменений
    /// - Parameters:
    ///   - row: строка
    ///   - col: столбец
    ///   - value: значение
    func makeMove(row: Int, col: Int, value: Int) {
        puzzle[row][col] = value
    }
    
    /// Решить судоку
    func solveAll() {
        puzzle = currentAnswer
    }
    
    /// Стереть значение в ячейке
    /// - Parameters:
    ///   - row: строка
    ///   - col: столбец
    func clearCell(row: Int, col: Int) {
        puzzle[row][col] = 0
    }
    
    /// Вспомогательная функция для решения судоки
    /// - Returns: решение
    private func solve() -> [[Int]] {
        var tmp = [[Int]](puzzle)
        return solveInner(_puzzle: &tmp)
    }
    
    /// Решение судоки:
    /// Алгоритм - backtracking
    /// - Parameter _puzzle: копия пазла
    /// - Returns: решенный пазл после выхода из рекурсии
    private func solveInner(_puzzle: inout [[Int]]) -> [[Int]] {
        /// Поиск пустых ячеек
        guard let emptyPos = findEmptyPosition(puzzle: _puzzle) else {
            return _puzzle
        }
        /// Координаты постой ячейки
        let (x, y) = emptyPos
        /// Поиск возможных значений для данной ячейки
        var possibleValues = findPossibleValues(puzzle: _puzzle, row: x, col: y)
        /// Перемешивание возможных значений для большой случайности
        possibleValues.shuffle()
        /// Поиск решения пазла для каждого возможного значения
        for possibleValue in possibleValues {
            _puzzle[x][y] = possibleValue
            /// Уход в глубину рекурсии
            let result = solveInner(_puzzle: &_puzzle)
            /// Выход их рекурсии
            if result.count != 1 {
                return result
            }
            _puzzle[x][y] = 0
        }
        /// if отсутствует решение
        return [[]]
    }
    
    /// Получение всех значений из строки судоки
    /// - Returns: Массив значений
    private func getRow(puzzle: [[Int]], row: Int) -> [Int] {
        puzzle[row]
    }
    
    /// Получение всех значений из столбца судоки
    /// - Returns: Массив значений
    private func getCol(puzzle: [[Int]], col: Int) -> [Int] {
        var result = [Int]()
        for row in puzzle {
            result.append(row[col])
        }
        return result
    }
    
    /// Получение всех значение из блока судоки
    /// - Returns: Массив значений
    private func getBlock(puzzle: [[Int]], row: Int, col: Int) -> [Int] {
        var result = [Int]()
        
        let startX = row - row % size
        let startY = col - col % size
        
        for i in 0..<size {
            for j in 0..<size {
                result.append(puzzle[startX + i][startY + j])
            }
        }
        
        return result
    }
    
    /// Поиск возможных правильный значений в заданной ячейки для решения судоки
    /// - Returns: Массив значений
    private func findPossibleValues(puzzle: [[Int]], row: Int, col: Int) -> [Int] {
        var possible = Set(1..<sideLen + 1)
        possible = possible.filter { !getRow(puzzle: puzzle, row: row).contains($0) }
        possible = possible.filter { !getCol(puzzle: puzzle, col: col).contains($0) }
        possible = possible.filter { !getBlock(puzzle: puzzle, row: row, col: col).contains($0) }
        
        return Array(possible).shuffled()
    }
    
    /// Поиск пустых ячеек
    /// - Returns: tuple из координат по x и y
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
