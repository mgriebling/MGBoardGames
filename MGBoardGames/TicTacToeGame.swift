//
//  ReversiGame.swift
//  MGReversi
//
//  Created by Mike Griebling on 2021-09-10.
//

import SwiftUI
//
//@Observable class TicTacToeGame {
//    
//    static let name = "MG Tic-Tac-Toe Game"
//    static let maxRows = 3
//    static let maxColumns = maxRows  // square game board
//    
//    static func newGame() -> TicTacToeGameBoard {
//        TicTacToeGameBoard(rows: maxRows, columns: maxColumns)
//    }
//    
//    private(set) var gameBoard = newGame()
//    
//    private static let blank = [Bool](repeating: false, count: maxColumns)
//    private static let cleared = [[Bool]](repeating: blank, count: maxRows)
//    
//    var flipped = cleared
//
//    var board: [CellState] { gameBoard.board }
//    
//    var player: GamePiece { gameBoard.nextMove }
//    var computer: ComputerPlayer?
//    
//    var whiteScore: Int { gameBoard.score(.whitePiece) }
//    var blackScore: Int { gameBoard.score(.blackPiece) }
//    
//    var isGameOver: Bool { gameBoard.hasGameFinished }
//    
//    func piece (_ row: Int, column: Int) -> CellState { gameBoard[row, column] }
//    
//    func isValidMove(_ row: Int, column: Int) -> Bool { gameBoard.isValidMoveTo(row, andColumn: column) }
//    
//    var rows: Int    { gameBoard.rows }
//    var columns: Int { gameBoard.columns }
//    
//    func setUpFlipped() {
////        flipped = ReversiGame.cleared
////        for row in 0..<ReversiGame.maxRows {
////            for column in 0..<ReversiGame.maxColumns {
////                if gameBoard[row, column] == .blackPiece {
////                    flipped[row][column] = true
////                }
////            }
////        }
//    }
//    
//    init() {
//        restoreGame()
////        computer = ComputerPlayer(board: self, computerColour: .whitePiece, maxDepth: 4)
//    }
//    
//    deinit {
//        saveGame()
//    }
//    
//    // MARK: - Intents
//    
//    func saveGame() {
//        let prefs = UserDefaults.standard
//        if let data = try? JSONEncoder().encode(gameBoard) {
//            prefs.set(data, forKey: ReversiGame.name)
//        }
//    }
//    
//    func restoreGame() {
//        let prefs = UserDefaults.standard
//        if let data = prefs.data(forKey: TicTacToeGame.name) {
//            if let board = try? JSONDecoder().decode(TicTacToeGameBoard.self, from: data) {
//                gameBoard = board
//                setUpFlipped()
//                return
//            }
//        }
//        gameBoard = TicTacToeGame.newGame()
//        setUpFlipped()
//    }
//    
//    func setComputerPiece(_ row: Int, column: Int) {
//        gameBoard.makeMoveTo(row, column: column)
//        setUpFlipped()
//    }
//    
//    func setPiece(_ row: Int, column: Int) -> Bool {
//        if gameBoard.isValidMoveTo(row, andColumn: column) {
//            gameBoard.makeMoveTo(row, column: column)
//            print("Player = \(player)")
//            if player == computer?.computerColour {
//                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _flipped in
//                    self.computer?.makeNextMove()
//                }
//            }
//            setUpFlipped()
//            return true
//        }
//        return false
//    }
//    
//    func newGame() {
//        gameBoard = TicTacToeGame.newGame()
//        setUpFlipped()
//    }
//    
//}
//
//extension GamePiece : CustomStringConvertible {
//    // Make the symbols printable
//    public var description: String {
//        switch self {
//        case .blackPiece: return "❌"
//        case .whitePiece: return "⭕️"
//        default:          return " "
//        }
//    }
//}
//
//extension CellState: CustomStringConvertible {
//    public var description: String { self.state.description }
//}
//
//
//
