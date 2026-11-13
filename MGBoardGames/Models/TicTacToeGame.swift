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
	var other: Self { self.isBlack ? .whitePiece : .blackPiece }
	
	static var error: Self { .invalid }
	static var empty: Self { .blank }
	static var start: Self { .blackPiece }
}

struct TicTacToeBoard: Board {
	typealias E = TicTacToePieces
	
	let rows: Int
	let columns: Int
	
	/// Game board with rows x columns positions
	private var pieces: [E] = []
	
	/// Count of all pieces on the board
	var count: Int { pieces.count { !$0.isEmpty } }
	
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
	
	private let ThreeInARow = [
		[ 0, 1, 2 ],
		[ 3, 4, 5 ],
		[ 6, 7, 8 ],
		[ 0, 3, 6 ],
		[ 1, 4, 7 ],
		[ 2, 5, 8 ],
		[ 0, 4, 8 ],
		[ 2, 4, 6 ]
	]
	
	private let HeuristicScore = [
		[    0,  -1,  -10,  -100 ],
		[    1,   0,    0,     0 ],
		[   10,   0,    0,     0 ],
		[  100,   0,    0,     0 ]
	]
	
	// Determine a heuristic score
	func score(_ player: E) -> Int {
		// https://kartikkukreja.wordpress.com/2013/03/30/heuristic-function-for-tic-tac-toe/
		var score = 0
		let opponent = player.other

		for i in 0..<ThreeInARow.count {
			var players = 0
			var others = 0
			for j in 0..<ThreeInARow[0].count {
				let piece = pieces[ThreeInARow[i][j]]
				if piece == player {
					players += 1
				} else if piece == opponent {
					others += 1
				}
			}
			score += HeuristicScore[players][others]
		}
		
		return score
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
		// excludes ThreeInARow and HeuristicScore
	}
}

@Observable final class TicTacToeGame: Game {
	typealias E = TicTacToePieces
	
	let name = "Tic-Tac-Toe"
	var board: TicTacToeBoard
	var activePlayer: Player
	var activeColor: E.Enum { color(for: activePlayer) }
	var isDraw: Bool = false
	
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
		let incRight: NavigationFunction = { pos in pos.col += 1 }
		let incDown: NavigationFunction = { pos in pos.row += 1 }
		let incDR: NavigationFunction = { pos in pos.row += 1; pos.col += 1 }
		let incDL: NavigationFunction = { pos in pos.row += 1; pos.col -= 1  }
		let win3 =
			threeInARow(Position(row: 0, col: 0), incRight) || // check rowa
			threeInARow(Position(row: 1, col: 0), incRight) ||
			threeInARow(Position(row: 2, col: 0), incRight) ||
			threeInARow(Position(row: 0, col: 0), incDown)  || // check cols
			threeInARow(Position(row: 0, col: 1), incDown)  ||
			threeInARow(Position(row: 0, col: 2), incDown)  ||
			threeInARow(Position(row: 0, col: 0), incDR)    || // check diagonals
			threeInARow(Position(row: 0, col: 2), incDL)
		if win3 {
			isDraw = false
			return true
		} else {
			if board.count == rows * columns {
				// board is full & no winner
				isDraw = true
				return true
			}
		}
		return false
	}
	
	private func threeInARow(_ p: Position, _ move: NavigationFunction) -> Bool {
		let startPiece = self[p]
		var p = p
		for _ in 0..<3 {
			let piece = self[p]
			if piece.isEmpty || startPiece != piece { return false }
			move(&p) // next position
		}
		return true
	}
	
	var rows: Int    { board.rows }
	var columns: Int { board.columns }
	
	init(rows: Int = 3, columns: Int = 3) {
		let player1 = Player(name: "Dummy1", colour: .white)
		self.board = TicTacToeBoard(rows: rows, columns: columns)
		self.player1 = player1
		self.player2 = Player(name: "Dummy2", colour: .white)
		self.activePlayer = player1
		self.isDraw = false
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
		return true
	}

	// No initial pieces to set up
	func setupInitialPieces() {  }
	
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
