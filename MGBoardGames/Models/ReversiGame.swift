//
//  ReversiGame.swift
//  MGReversi
//
//  Created by Mike Griebling on 2021-09-10.
//

import Foundation

enum ReversiPieces: Int, GamePieceEnum  {

	case blackPiece = 0, whitePiece, blank, invalid
	
	var isWhite: Bool { self == .whitePiece }
	var isBlack: Bool { self == .blackPiece }
	var isEmpty: Bool { self == .blank }
	
	var description: String {
		switch self {
			case .invalid:	  "🚫"
			case .blackPiece: "⚫️"
			case .whitePiece: "⚪️"
			default:          ""
		}
	}
	
	static var error: Self { .invalid }
	static var empty: Self { .blank }
	static var start: Self { .blackPiece }
	
	static func flip(_ x: ReversiPieces) -> ReversiPieces {
		switch x {
			case .blackPiece: .whitePiece
			case .whitePiece: .blackPiece
			default: x
		}
	}
}

struct ReversiBoard: Board {
	typealias E = ReversiPieces
	
	let rows: Int
	let columns: Int
	
	/// Game board with rows x columns positions
	private var pieces: [E] = []
	
	init(rows: Int, columns: Int) {
		self.rows = rows
		self.columns = columns
		clearAll()
	}
	
	mutating func clear(_ position: Position) { self[position] = E.blank }
	
	mutating func clearAll() {
		pieces = Array(repeating: E.empty, count: rows * columns)
	}
	
	// Movement functions for reversi inspired by SHCReversi demo
	let moves: [NavigationFunction] = [
		{ pos in pos.col += 1 },             	// move right
		{ pos in pos.col -= 1 },             	// move left
		{ pos in pos.row -= 1 },                // move up
		{ pos in pos.row += 1 },                // move down
		{ pos in pos.row += 1; pos.col += 1 },  // move right up
		{ pos in pos.row -= 1; pos.col += 1 },  // move right down
		{ pos in pos.row += 1; pos.col -= 1 },  // move left up
		{ pos in pos.row -= 1; pos.col -= 1 }   // move left down
	]
	
	// Placement of reversi pieces along with opponent flipping
	mutating func move(to position: Position, for activeColor: E.Enum) {
		self[position] = activeColor
		
		// check the eight playing directions and flip pieces
		for move in moves {
			flipOpponentsPieces(for: position, with: move, to: activeColor)
		}
	}
	
	mutating func flipOpponentsPieces(for position: Position, with move: NavigationFunction, to state: E) {
		// are any pieces surrounded in this direction?
		guard moveSurroundingPieces(for: position, with: move, to: state) else { return }
		
		let opponentsState = ReversiPieces.flip(state)
		var currentState = ReversiPieces.blank
		var pos = position      // need mutability
		repeat {
			// advance to the next cell
			move(&pos)
			currentState = self[pos]
			self[pos] = state
		} while pos.col >= 0 && pos.col < columns && pos.row >= 0 && pos.row < rows && currentState == opponentsState
	}
	
	func moveSurroundingPieces(for selected: Position, with move: NavigationFunction, to state: ReversiPieces) -> Bool {
		var pos = selected

		// advances row, column values to next cell
		move(&pos)

		// check within the bounds of the board
		var index = 1
		while pos.row >= 0 && pos.row < rows && pos.col >= 0 && pos.col < columns {
			let currentState = self[pos]
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
			move(&pos)
		}
		return false
	}
	
	func score(_ playerColor: E) -> Int {
		pieces.count { $0 == playerColor }
	}
	
	mutating func set(positions: [Position], to piece: E) {
		positions.forEach { self[$0] = piece }
	}
	
	private func index(from pos: Position) -> Int {
		pos.col + rows * pos.row
	}
	
	subscript(position: Position) -> E {
		get {
			let index = index(from: position)
			guard index >= 0 && index < pieces.count else { return E.blank }
			return pieces[index]
		}
		set {
			let index = index(from: position)
			guard index >= 0 && index < pieces.count else { return }
			pieces[index] = newValue
		}
	}
	
	enum CodingKeys: String, CodingKey {
		case rows, columns, pieces
		// moves
	}
	
}

@Observable final class ReversiGame: Game {
	typealias E = ReversiPieces
	
	let name = "Reversi"
	var board: ReversiBoard
	var activePlayer: Player
	var activeColor: E.Enum { color(for: activePlayer) }
	
	var player1: Player {
		didSet {
			if player1.isStarting {
				activePlayer = player1
			}
		}
	}
	var player2: Player {
		didSet {
			if player2.isStarting {
				activePlayer = player1
			}
		}
	}
	
	let errorPiece = ReversiPieces.invalid
	let whitePiece = ReversiPieces.whitePiece
	let blackPiece = ReversiPieces.blackPiece
	
	var player1Score: Int { board.score(color(for: player1)) }
	var player2Score: Int { board.score(color(for: player2)) }
	
	var gameIsOver: Bool {
		(!canPlayerMakeMove(player1) && !canPlayerMakeMove(player2)) ||
		(player1Score + player2Score == rows * columns) // board is full
	}
	
	/// Convenience getters
	var rows: Int    { board.rows }
	var columns: Int { board.columns }
	
	init(rows: Int = 8, columns: Int = 8) {
		let player1 = Player(name: "Dummy1", colour: .white)
		self.board = ReversiBoard(rows: rows, columns: columns)
		self.player1 = player1
		self.player2 = Player(name: "Dummy2", colour: .white)
		self.activePlayer = player1
		setupInitialPieces()
	}
	
	func newGame() {
		self.board = ReversiBoard(rows: rows, columns: columns)
		setupInitialPieces()
	}
	
	func color(for player: Player) -> E.Enum {
		player.colour == .black ? ReversiPieces.blackPiece : .whitePiece
	}
	
	func validMoves(for player: Player) -> [Position] {
		var moves = [Position]()
		for row in 0..<rows {
			for column in 0..<columns {
				if isValidMove(to: Position(row: row, col: column), for: player) {
					moves.append(Position(row: row, col: column))
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
	
	/// Simple computer algorithm to decide on the next move.  Check one move ahead and see
	/// which play results in the highest score.
	func makeNextMove() {
		let Empty = Position(row: -1, col: -1)
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
	
	subscript(_ position: Position) -> E.Enum {
		get { board[position] }
		set { board[position] = newValue }
	}
	
	func isValidMove(to selected: Position, for player: Player) -> Bool {
		guard board[selected] == .blank else { return false }
		
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
	
		board.move(to: Position(row: halfRow-1, col:halfColumn-1), for: whitePiece)
		board.move(to: Position(row: halfRow,   col:halfColumn),   for: whitePiece)
		board.move(to: Position(row: halfRow-1, col:halfColumn),   for: blackPiece)
		board.move(to: Position(row: halfRow,   col:halfColumn-1), for: blackPiece)
	}
	
	func canPlayerMakeMove(_ state: Player) -> Bool {
		for row in 0..<rows {
			for column in 0..<columns {
				if isValidMove(to: Position(row: row, col: column), for: state) { return true }
			}
		}
		return false
	}
	
	func handleTap(at selected: Position) {
		guard !gameIsOver else { return }
		if setPiece(selected) {
			saveGame() // all is ok
		} else {
			let pieceInPlace = board[selected]
			board.move(to: selected, for: .invalid)
			Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
				// clear illegal move square after some time
				if pieceInPlace == .blank {
					self.board.clear(selected)
				} else {
					self.board[selected] = pieceInPlace
				}
			}
		}
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
    
	func setPiece(_ selected: Position) -> Bool {
		if isValidMove(to: selected, for: activePlayer) {
			board.move(to: selected, for: color(for: activePlayer))
			print("Player = \(activePlayer.name)")
			switchTurns()
			print("New Player = \(activePlayer.name)")
			if activePlayer.kind == .computer {
				print("Computer moving...")
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _flipped in
                    self.makeNextMove()
                }
            }
            return true
        }
        return false
    }
}



