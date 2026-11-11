//
//  ReversiGame.swift
//  MGReversi
//
//  Created by Mike Griebling on 2021-09-10.
//

import Foundation

enum ReversiPieces: Int, GamePieceEnum  {
	case blackPiece = 0, whitePiece, blank, invalid
	
	var description: String {
		switch self {
			case .invalid:	  "🚫"
			case .blackPiece: "⚫️"
			case .whitePiece: "⚪️"
			default:          " "
		}
	}
	
	var flipped: Self {
		if self == .blackPiece { return .whitePiece }
		if self == .whitePiece { return .blackPiece }
		return self
	}
	
	static var error: ReversiPieces { .invalid }
	static var empty: ReversiPieces { .blank }
	static var start: Self { .blackPiece }
	
	static func flip(_ x: ReversiPieces) -> ReversiPieces {
		x == .blackPiece ? .whitePiece : .blackPiece
	}
}

extension GameBoard {
	// Movement functions inspired by SHCReversi demo
	typealias NavigationFunction = (inout Int, inout Int) -> ()
	var moves: [NavigationFunction] { [
		{ row, column in column += 1 },             // move right
		{ row, column in column -= 1 },             // move left
		{ row, column in row -= 1 },                // move up
		{ row, column in row += 1 },                // move down
		{ row, column in row += 1; column += 1 },   // move right up
		{ row, column in row -= 1; column += 1 },   // move right down
		{ row, column in row += 1; column -= 1 },   // move left up
		{ row, column in row -= 1; column -= 1 }    // move left down
	] }
	
	mutating func move(to position: BoardCoordinate, for activeColor: E.Enum) {
		pieces[position] = activeColor
		
		// check the eight playing directions and flip pieces
		for move in moves {
			flipOpponentsPieces(for: position, with: move, to: activeColor)
		}
	}
	
	mutating func flipOpponentsPieces(for position: BoardCoordinate, with move: NavigationFunction, to state: E.Enum) {
		// are any pieces surrounded in this direction?
		guard moveSurroundingPieces(for: position, with: move, to: state) else { return }
		
		let opponentsState = E.flip(state)
		var currentState = E.empty
		var row = position.row, column = position.col      // need mutability
		repeat {
			// advance to the next cell
			move(&row, &column)
			let pos = BoardCoordinate(row: row, col: column)
			if let value = pieces[pos] {
				currentState = value
			} else {
				currentState = E.empty
			}
			pieces[pos] = state
			
		} while column >= 0 && column < columns && row >= 0 && row < rows && currentState == opponentsState
	}
	
	func moveSurroundingPieces(for selected: BoardCoordinate, with move: NavigationFunction, to state: E.Enum) -> Bool {
		var row = selected.row, column = selected.col  // make these mutable

		// advances row, column values to next cell
		move(&row, &column)

		// check within the bounds of the board
		var index = 1
		while row >= 0 && row < rows && column >= 0 && column < columns {
			let currentState = pieces[BoardCoordinate(row: row, col: column)]
			// the cell that is immediate neighbour must be of the opposite colour
			if index == 1 {
				if currentState != E.flip(state) { return false }
			} else {
				if currentState == state { return true }
				
				// if we have reached an empty cell - fail
				if currentState == E.empty { return false }
			}
			
			index += 1
			
			// advance to the next cell
			move(&row, &column)
		}
		return false
	}
	
	func score(_ playerColor: E.Enum) -> Int {
		pieces.count { (key, value) in
			playerColor == value
		}
	}
}

@Observable final class ReversiGame: Game {
	typealias ReversiBoard = GameBoard<ReversiPieces>
	
	let name = "Reversi"
	var board: ReversiBoard
	var activePlayer: Player
	var activeColor: E.Enum { color(for: activePlayer) }
	
	var player1: Player // { settings.player1 }
	var player2: Player // { settings.player2 }
	
	let errorPiece = ReversiPieces.invalid
	let whitePiece = ReversiPieces.whitePiece
	let blackPiece = ReversiPieces.blackPiece
	
	var player1Score: Int { board.score(color(for: player1)) }
	var player2Score: Int { board.score(color(for: player2)) }
	
	var gameIsOver: Bool {
		(!canPlayerMakeMove(player1) && !canPlayerMakeMove(player2)) ||
		(player1Score + player2Score == rows * columns) // board is full
	}
	
	var rows: Int    { board.rows }
	var columns: Int { board.columns }
	
	init(rows: Int = 8, columns: Int = 8, player1: Player, player2: Player) {
		self.board = ReversiBoard(rows: rows, columns: columns)
		self.player1 = player1
		self.player2 = player2
		self.activePlayer = player1.colour == .black ? player1 : player2
		setupInitialPieces()
	}
	
	func color(for player: Player) -> E.Enum {
		player.colour == .black ? ReversiPieces.blackPiece : .whitePiece
	}
	
	func gameStateChanged() {
		if activePlayer.kind == .computer {
			// pause for 1 second, then make a move
			DispatchQueue.main.asyncAfter(deadline: .now()+1) {
				self.makeNextMove()
			}
		}
	}
	
	func validMoves(for player: Player) -> [BoardCoordinate] {
		var moves = [BoardCoordinate]()
		for row in 0..<rows {
			for column in 0..<columns {
				if isValidMove(to: BoardCoordinate(row: row, col: column), for: player) {
					moves.append(BoardCoordinate(row: row, col: column))
				}
			}
		}
		return moves
	}
	
	func switchTurns() {
		let nextPlayerTemp: Player
		if activePlayer.colour == player1.colour {
			nextPlayerTemp = player2
		} else {
			nextPlayerTemp = player1
		}
		
		if canPlayerMakeMove(nextPlayerTemp) { activePlayer = nextPlayerTemp }
	}
	
	/// Computer algorithm to decide on the next move.  Check *n* moves ahead and see
	/// which play results in the highest score.
	func makeNextMove() {
		let Empty = BoardCoordinate(row: -1, col: -1)
		var bestMove = Empty
		var bestScore = Int.min
		
		// check every possible move, then select the one with the best 'score'
		let moves = validMoves(for: activePlayer)
		for move in moves {
			let nextMove = move
			
			// clone the current board
			var testBoard = board
			testBoard.move(to: nextMove, for: activeColor)
			
			// compute the score (i.e., difference between white and black pieces
			let scoreForMove = testBoard.score(activeColor)
			if scoreForMove > bestScore || bestScore == Int.min {
				bestScore = scoreForMove
				bestMove = nextMove
			}
		}
		
		if bestMove != Empty {
			board.move(to: bestMove, for: activeColor)
			switchTurns()
		}
	}
	
	subscript(_ position: BoardCoordinate) -> E.Enum {
		get { board[position] }
		set { board[position] = newValue }
	}
	
	subscript(_ row: Int, col: Int) -> E.Enum {
		get { self[BoardCoordinate(row: row, col: col)] }
		set { self[BoardCoordinate(row: row, col: col)] = newValue }
	}
	
	func isValidMove(to selected: BoardCoordinate, for player: Player) -> Bool {
		guard board.pieces[selected] == nil else { return false }
		
		// check moves in each direction
		let playerColor = color(for: player)
		for move in board.moves {
			if board.moveSurroundingPieces(for: selected, with: move, to: playerColor) { return true }
		}
		return false
	}

	func setupInitialPieces() {
		// Rule 2: set up the starting pieces with four central squares occupied
		let halfRow = board.rows/2
		let halfColumn = board.columns/2
	
		board.move(to: BoardCoordinate(row: halfRow-1, col:halfColumn-1), for: whitePiece)
		board.move(to: BoardCoordinate(row: halfRow,   col:halfColumn),   for: whitePiece)
		board.move(to: BoardCoordinate(row: halfRow-1, col:halfColumn),   for: blackPiece)
		board.move(to: BoardCoordinate(row: halfRow,   col:halfColumn-1), for: blackPiece)
	}
	
	func canPlayerMakeMove(_ state: Player) -> Bool {
		for row in 0..<rows {
			for column in 0..<columns {
				if isValidMove(to: BoardCoordinate(row: row, col: column), for: state) { return true }
			}
		}
		return false
	}
	
	func handleTap(at selected: BoardCoordinate) {
		guard board.isValid(coordinate: selected) else { return }
		if setPiece(selected) {
			// all is ok
		} else {
			board.move(to: selected, for: .invalid)
			Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
				self.board.clear(selected) // clear illegal move square after some time
			}
		}
		saveGame()
	}
    
    // MARK: - Intents
    
    func saveGame() {
        let prefs = UserDefaults.standard
        if let data = try? JSONEncoder().encode(board) {
            prefs.set(data, forKey: name)
        }
    }
    
    func restoreGame() {
        let prefs = UserDefaults.standard
        if let data = prefs.data(forKey: name) {
            if let board = try? JSONDecoder().decode(ReversiBoard.self, from: data) {
				self.board = board
                return
            }
        }
		self.board = ReversiBoard(rows: rows, columns: columns)
    }
    
	func setPiece(_ selected: BoardCoordinate) -> Bool {
		if isValidMove(to: selected, for: activePlayer) {
			board.move(to: selected, for: color(for: activePlayer))
			print("Player = \(activePlayer.name)")
			switchTurns()
			print("New Player = \(activePlayer.name)")
			if activePlayer.kind == .computer {
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _flipped in
                    self.makeNextMove()
                }
            }
            return true
        }
        return false
    }
    
    func newGame() {
		self.board = ReversiBoard(rows: rows, columns: columns)
    }
    
}



