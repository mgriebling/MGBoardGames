//
//  Select4Game.swift
//  MGBoardGames
//
//  Created by Mike Griebling on 2026-09-10.
//

import Foundation

enum Connect4Pieces: Int, GamePieceEnum  {
	case invalid = 0, blank
	case whitePiece, blackPiece
	
	var isWhite: Bool { self == .whitePiece }
	var isBlack: Bool { self == .blackPiece }
	var isEmpty: Bool { self == .blank }
	
	var description: String {
		switch self {
			case .invalid:	  "🚫"
			case .blackPiece: "🔴"
			case .whitePiece: "🟡"
			default:          ""
		}
	}
	
	static var error: Self { .invalid }
	static var empty: Self { .blank }
	static var start: Self { .blackPiece }
	static func flip(_ x: Connect4Pieces) -> Connect4Pieces { x }
}

struct Connect4Board: Board {
	typealias E = Connect4Pieces
	
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
	
	// Movement functions for Connect4s inspired by SHCConnect4s demo
	let moves: [NavigationFunction] = [ ]

	// Placement of Connect4s pieces along with opponent flipping
	mutating func move(to position: Position, for activeColor: E.Enum) {
		self[position] = activeColor
	}
	
	func score(_ playerColor: PlayerColor) -> Int {
		0 // pieces.count { $0 == playerColor }
	}
	
	mutating func set(positions: [Position], to piece: E) {
		positions.forEach { self[$0] = piece }
	}
	
	private func index(from pos: Position) -> Int {
		pos.col + columns * pos.row
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

@Observable final class Connect4Game: Game {
	typealias E = Connect4Pieces
	
	let name = "Connect 4"
	var board: Connect4Board
	var activePlayer: Player
	var activeColor: PlayerColor { activePlayer.colour }
	var activePiece: E.Enum { activeColor == .white ? whitePiece : blackPiece }
	var selectedPiece: Position? = nil
	var isDraw: Bool = false
	
	var player1: Player {
		didSet { if player1.isStarting { activePlayer = player1 } }
	}
	var player2: Player {
		didSet { if player2.isStarting { activePlayer = player2 } }
	}
	
	let errorPiece = Connect4Pieces.invalid
	
	var player1Score: Int { score(for: player1) }
	var player2Score: Int { score(for: player1) }
	
	var whitePiece: Connect4Pieces { E.whitePiece }
	var blackPiece: Connect4Pieces { E.blackPiece }
	
	var gameIsOver: Bool {
		false
	}
	
	let moves: [NavigationFunction] = []
	
	/// Convenience getters
	var rows: Int    { board.rows }
	var columns: Int { board.columns }
	
	init(rows: Int = 6, columns: Int = 7) {
		let player1 = Player(name: "Dummy1", colour: .white)
		self.board = Connect4Board(rows: rows, columns: columns)
		self.player1 = player1
		self.player2 = Player(name: "Dummy2", colour: .white)
		self.activePlayer = player1
		setupInitialPieces()
	}
	
	func score(for player: Player) -> Int {
		board.score(player.colour)
	}
	
	func newGame() {
		self.board = Connect4Board(rows: rows, columns: columns)
		setupInitialPieces()
	}
	
	func color(for player: Player) -> PlayerColor {
		player.colour
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
	/// which play results in the highest score. *selectedPiece* board position must be occupied.
	func makeNextMove() {
		guard let selectedPiece else { return }
		let activePiece = self[selectedPiece]
		let Empty = Position(row: -1, col: -1)
		var bestMove = Empty
		var bestScore = Int.min
		
		// check every possible move, then select the one with the best 'score'
		let moves = validMoves(for: activePlayer)
		for move in moves {
			let nextMove = move
			
			// clone the current board
			var testBoard = board
			testBoard.move(to: nextMove, for: activePiece)
			
			// compute the score (i.e., difference between white and black pieces
			let scoreForMove = testBoard.score(activeColor)
			if scoreForMove > bestScore || bestScore == Int.min {
				bestScore = scoreForMove
				bestMove = nextMove
			}
		}
		
		if bestMove != Empty {
			board.move(to: bestMove, for: activePiece)
			switchTurns()
		}
	}
	
	subscript(_ position: Position) -> E.Enum {
		get { board[position] }
		set { board[position] = newValue }
	}
	
	func countPieces(col: Int) -> Int {
		var count = 0
		for row in 0..<rows {
			if !self[Position(row: row, col: col)].isEmpty {
				count += 1
			}
		}
		return count
	}
	
	func isValidMove(to selected: Position, for player: Player) -> Bool {
		countPieces(col: selected.col) < rows
	}

	func setupInitialPieces() {
		// board is cleared
	}
	
	func canPlayerMakeMove(_ state: Player) -> Bool {
		return true
	}
	
	func handleTap(at selected: Position) {
		guard !gameIsOver else { return }
		// determine the next row for this column
		let row = countPieces(col: selected.col)
		if setPiece(Position(row: row, col: selected.col)) {
			saveGame() // all is ok
		} else {
			// invalid move
			print("Invalid move...")
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
            if let board = try? JSONDecoder().decode(Connect4Board.self, from: data) {
				self.board = board
                return
            }
        }
		self.board = Connect4Board(rows: rows, columns: columns)
    }
    
	func setPiece(_ selected: Position) -> Bool {
		if isValidMove(to: selected, for: activePlayer) {
			//guard let selectedPiece else { return false }
			print("Move piece")
			board.move(to: selected, for: activePiece)
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



