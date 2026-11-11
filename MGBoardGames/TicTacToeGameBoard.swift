//
//  GameBoard.swift
//  MGReversi
//
//  Created by Mike Griebling on 2021-09-10.
//

import Foundation

//public struct TicTacToeGameBoard : Codable {
//    
//    let rows: Int
//    let columns: Int
//    
//    private(set) var nextMove: GamePiece
//    private(set) var board: [CellState]
//    
//    // Movement functions inspired by SHCReversi demo
//    typealias NavigationFunction = (inout Int, inout Int) -> ()
//    private var moves: [NavigationFunction] { [
//        { row, column in column += 1 },             // move right
//        { row, column in column -= 1 },             // move left
//        { row, column in row -= 1 },                // move up
//        { row, column in row += 1 },                // move down
//        { row, column in row += 1; column += 1 },   // move right up
//        { row, column in row -= 1; column += 1 },   // move right down
//        { row, column in row += 1; column -= 1 },   // move left up
//        { row, column in row -= 1; column -= 1 }    // move left down
//    ] }
//    
//    public typealias Position = (row: Int, column: Int)
//    
//    public func score(_ player: GamePiece) -> Int { board.filter{ $0 == player }.count }
//    
//    var hasGameFinished : Bool {
//		!canPlayerMakeMove(.blackPiece) && !canPlayerMakeMove(.whitePiece)
//	}
//    
//    init(rows: Int, columns: Int) {
//        // starting configuration with central squares occupied
//        self.rows = rows
//        self.columns = columns
//        self.nextMove = .blackPiece   // Rule 1: Black moves first
//        
//        // clear the board
//        board = [CellState](repeating: CellState(.empty), count: rows*columns)
//    }
//
////    func moveSurroundingPiecesFor(_ row: Int, andColumn column: Int, with move: NavigationFunction, to state: GamePiece) -> Bool {
////        var row = row, column = column  // make these mutable
////
////        // next cell
////        move(&row, &column)
////
////        // check within the bounds of the board
////        var index = 1
////        while row >= 0 && row < rows && column >= 0 && column < columns {
////            let currentState = self[row, column]
////
////            // the cell that is immediate neighbour must be of the opposite colour
////            if index == 1 {
////                if currentState != state.flipped { return false }
////            } else {
////                if currentState == state { return true }
////                
////                // if we have reached an empty cell - fail
////                if currentState == .empty { return false }
////            }
////            
////            index += 1
////            
////            // advance to the next cell
////            move(&row, &column)
////        }
////        return false
////    }
//    
//    func isValidMoveTo(_ row: Int, andColumn column: Int) -> Bool { isValidMoveTo(row, andColumn: column, for: nextMove) }
//    
//    func isValidMoveTo(_ row: Int, andColumn column: Int, for state: GamePiece) -> Bool {
//        self[row, column].isEmpty
//        
//        // check moves in each direction
////        for move in moves {
////            if moveSurroundingPiecesFor(row, andColumn: column, with: move, to: state) { return true }
////        }
////        return false
//    }
//    
//    func canPlayerMakeMove(_ state: GamePiece) -> Bool {
//        for row in 0..<rows {
//            for column in 0..<columns {
//                if isValidMoveTo(row, andColumn: column, for: state) { return true }
//            }
//        }
//        return false
//    }
//    
////    mutating func flipOpponentsPiecesFor(_ row: Int, andColumn column: Int, with move: NavigationFunction, to state: GamePiece) {
////        // are any pieces surrounded in this direction?
////        guard moveSurroundingPiecesFor(row, andColumn: column, with: move, to: state) else { return }
////        
////        let opponentsState = state.flipped
////        var currentState = GamePiece.empty
////        var row = row, column = column      // need mutability
////        repeat {
////            // advance to the next cell
////            move(&row, &column)
////            currentState = self[row, column].state
////            self[row, column].state = state
////            
////        } while column >= 0 && column < columns && row >= 0 && row < rows && currentState == opponentsState
////    }
//    
//    public mutating func makeMoveTo(_ row: Int, column: Int) {
//        self[row, column].state = nextMove
//        
//        // check the eight playing directions and flip pieces
////        for move in moves {
////            flipOpponentsPiecesFor(row, andColumn: column, with: move, to: nextMove)
////        }
//        
//        switchTurns()
//    }
//    
//    mutating func switchTurns() {
//        let nextMoveTemp = nextMove.flipped
//        if canPlayerMakeMove(nextMoveTemp) { nextMove = nextMoveTemp }
//    }
//    
//    // not sure if this is the most efficient way of accessing a board piece?
//    private func indexOf(_ row: Int, column: Int) -> Int {
//        assert(row >= 0 && row < rows && column >= 0 && column < columns, "Index of board is out of limits")
//        return row * columns + column
//    }
//    
//    public subscript(row:Int, column: Int) -> CellState {
//        get { board[indexOf(row, column: column)] }
//        set { board[indexOf(row, column: column)] = newValue }
//    }
//    
//}
