//
//  ChessGame.swift
//  MGBoardGames
//
//  Created by Mike Griebling on 2026-09-10.
//

import SwiftUI

enum CheckerPieces: GamePieceEnum {
	case blank, invalid
	case checker(PlayerColor)
	case king(PlayerColor)
	
	var color: PlayerColor? {
		switch self {
			case .checker(let color),
				 .king(let color):
			return color
		default:
			return nil
		}
	}
	
	var isWhite: Bool { color == .white }
	var isBlack: Bool { color == .black }
	var isEmpty: Bool { self == Self.blank }
	
	var image: ImageResource {
		switch self {
			case .king(.white):    .whiteCheckerKing
			case .king(.black):    .blackCheckerKing
			case .checker(.black): .blackChecker
			case .checker(.white): .whiteChecker
			case .invalid: 	 	   .circleSlash
			default:         	   .blank
		}
	}
	
	static var error: Self { .invalid }
	static var empty: Self { .blank }
	static var start: PlayerColor { .black }
}

struct CheckerBoard: Board {
	typealias E = CheckerPieces
	
	let rows = 8
	let columns = 8
	let itemsInARow = 0  // N/A
	
	/// Game board with rows x columns positions
	private var pieces = [E]()
	
	init() {
		clearAll()
	}
	
	mutating func clear(_ position: Position) { self[position] = E.blank }
	
	mutating func clearAll() {
		pieces = Array(repeating: E.empty, count: rows * columns)
	}
	
//	// Movement functions for Checkers inspired by SHCCheckers demo
//	let moves: [NavigationFunction] = [
//		{ pos in pos.row += 1; pos.col += 1 },  // move right up
//		{ pos in pos.row -= 1; pos.col += 1 },  // move right down
//		{ pos in pos.row += 1; pos.col -= 1 },  // move left up
//		{ pos in pos.row -= 1; pos.col -= 1 }   // move left down
//	]
	
	// Placement of Checkers pieces along with opponent flipping
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
		case pieces
		// moves
	}
	
}

@Observable final class CheckerGame: Game {
	typealias E = CheckerPieces
	
	let name = "Checkers"
	var board: CheckerBoard
	var activePlayer: Player
	var activeColor: PlayerColor { activePlayer.colour }
	var selectedPiece: Position? = nil
	var isDraw: Bool = false
	
	var player1: Player {
		didSet { if player1.isStarting { activePlayer = player1 } }
	}
	var player2: Player {
		didSet { if player2.isStarting { activePlayer = player2 } }
	}
	
	let errorPiece = CheckerPieces.invalid
	
	var player1Score: Int { score(for: player1) }
	var player2Score: Int { score(for: player1) }
	
	var gameIsOver: Bool {
		false
	}
	
	let moves: [NavigationFunction] = []
	
	/// Convenience getters
	var rows: Int    { board.rows }
	var columns: Int { board.columns }
	
	init() {
		let player1 = Player(name: "Dummy1", colour: .white)
		self.board = CheckerBoard()
		self.player1 = player1
		self.player2 = Player(name: "Dummy2", colour: .white)
		self.activePlayer = player1
		setupInitialPieces()
	}
	
	func score(for player: Player) -> Int {
		board.score(player.colour)
	}
	
	func newGame() {
		self.board = CheckerBoard()
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
	
	func isValidMove(to selected: Position, for player: Player) -> Bool {
//		guard let selectedPiece else { return false }
		
		// check moves in each direction
//		let piece = self[selectedPiece]
//		for moves in moves[piece] {
//			
//		}
	
		return false
	}

	func setupInitialPieces() {
		for i in 0...7 {
			if i.isMultiple(of: 2) {
				board.move(to: Position(row: 1, col: i), for: .checker(.black))
				board.move(to: Position(row: 5, col: i), for: .checker(.white))
				board.move(to: Position(row: 7, col: i), for: .checker(.white))
			} else {
				board.move(to: Position(row: 0, col: i), for: .checker(.black))
				board.move(to: Position(row: 2, col: i), for: .checker(.black))
				board.move(to: Position(row: 6, col: i), for: .checker(.white))
			}
		}
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
		if selectedPiece == nil, board[selected] != .empty {
			// mark selectedPiece position on the board
			self.selectedPiece = selected
			return
		} else if let _ = selectedPiece, selected == selectedPiece {
			// undo the selection
			self.selectedPiece = nil
			return
		} else if let _ = selectedPiece, board[selected] != .empty {
			// pick another piece
			self.selectedPiece = selected
			return
		}
		if setPiece(selected) {
			saveGame() // all is ok
		} else {
			// invalid move
			let pieceInPlace = board[selected]
			let pieceIsBlank = pieceInPlace == .blank
			board.move(to: selected, for: .invalid)
			Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
				// clear illegal move square after some time
				if pieceIsBlank {
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
            if let board = try? JSONDecoder().decode(CheckerBoard.self, from: data) {
				self.board = board
                return
            }
        }
		self.board = CheckerBoard()
    }
    
	func setPiece(_ selected: Position) -> Bool {
		if isValidMove(to: selected, for: activePlayer) {
			guard let selectedPiece else { return false }
			let activePiece = self[selectedPiece]
			self[selectedPiece] = .empty
			self.selectedPiece = nil
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



