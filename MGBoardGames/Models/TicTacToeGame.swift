//
//  TicTacToeGame.swift
//  MGBoardGames
//
//  Created by Mike Griebling on 2021-09-10.
//

import Foundation

enum TicTacToePieces: Int, GamePieceEnum  {
	case blackPiece = 0, whitePiece, blank, invalid
	
	var description: String {
		switch self {
			case .invalid:	  "circle.slash"
			case .blackPiece: "xmark"
			case .whitePiece: "circle"
			default:          ""
		}
	}
	
	var isWhite: Bool { self == .whitePiece }
	var isBlack: Bool { self == .blackPiece }
	var isEmpty: Bool { self == .blank }
	
	static var error: Self { .invalid }
	static var empty: Self { .blank }
	static var start: Self { .blackPiece }
	static func flip(_ x: Self) -> Self { x }
}

struct TicTacToeBoard: Board {
	typealias E = TicTacToePieces
	
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
	
	// Placement of reversi pieces along with opponent flipping
	mutating func move(to position: Position, for activeColor: E.Enum) {
		self[position] = activeColor
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

@Observable final class TicTacToeGame: Game {
	typealias E = TicTacToePieces
	
	let name = "Tic-Tac-Toe"
	var board: TicTacToeBoard
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
				activePlayer = player2
			}
		}
	}
	
	let errorPiece = TicTacToePieces.invalid
	let whitePiece = TicTacToePieces.whitePiece
	let blackPiece = TicTacToePieces.blackPiece
	
	var player1Score: Int { board.score(color(for: player1)) }
	var player2Score: Int { board.score(color(for: player2)) }
	
	var gameIsOver: Bool {
		(player1Score + player2Score == rows * columns) // board is full
	}
	
	var rows: Int    { board.rows }
	var columns: Int { board.columns }
	
	init(rows: Int = 3, columns: Int = 3, player1: Player, player2: Player) {
		self.board = TicTacToeBoard(rows: rows, columns: columns)
		self.player1 = player1
		self.player2 = player2
		self.activePlayer = player1.colour == .black ? player1 : player2
		setupInitialPieces()
	}
	
	func newGame() {
		self.board = TicTacToeBoard(rows: rows, columns: columns)
		setupInitialPieces()
	}
	
	func color(for player: Player) -> E.Enum {
		player.colour == .black ? TicTacToePieces.blackPiece : .whitePiece
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
		print("Invalid move to \(selected)")
		return true
	}

	func setupInitialPieces() {
		// No initial pieces to set up
//		let halfRow = board.rows/2
//		let halfColumn = board.columns/2
//		board.move(to: Position(row: halfRow, col:halfColumn), for: blackPiece)
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
		print("Handling tap...")
//		guard isValidMove(to: selected, for: activePlayer) else { return }
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
			if let board = try? JSONDecoder().decode(TicTacToeBoard.self, from: data) {
				self.board = board
				return
			}
		}
		self.board = TicTacToeBoard(rows: rows, columns: columns)
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
