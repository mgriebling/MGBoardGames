//
//  ChessGame.swift
//  MGChess
//
//  Created by Mike Griebling on 2021-09-10.
//

import SwiftUI

enum ChessPieces: Int, GamePieceEnum  {
	case blank = 0, invalid
	case wKing, wQueen, wBishop, wKnight, wRook, wPawn
	case bKing, bQueen, bBishop, bKnight, bRook, bPawn
	
	var isWhite: Bool { rawValue >= Self.wKing.rawValue && rawValue <= Self.wPawn.rawValue }
	var isBlack: Bool { rawValue >= Self.bKing.rawValue && rawValue <= Self.bPawn.rawValue }
	var isEmpty: Bool { self == .blank }
	
	var description: String {
		switch self {
			case .invalid: "circleSlash"
			case .wKing:   "whiteKing"
			case .wQueen:  "whiteQueen"
			case .wBishop: "whiteBishop"
			case .wKnight: "whiteKnight"
			case .wRook:   "whiteRook"
			case .wPawn:   "whitePawn"
			case .bKing:   "blackKing"
			case .bQueen:  "blackQueen"
			case .bBishop: "blackBishop"
			case .bKnight: "blackKnight"
			case .bRook:   "blackRook"
			case .bPawn:   "blackPawn"
			default:       ""
		}
	}
	
	var image: ImageResource {
		switch self {
			case .wKing:   .whiteKing
			case .wQueen:  .whiteQueen
			case .wBishop: .whiteBishop
			case .wKnight: .whiteKnight
			case .wRook:   .whiteRook
			case .wPawn:   .whitePawn
			case .bKing:   .blackKing
			case .bQueen:  .blackQueen
			case .bBishop: .blackBishop
			case .bKnight: .blackKnight
			case .bRook:   .blackRook
			case .bPawn:   .blackPawn
			case .invalid: .circleSlash
			default:       .blank
		}
	}
	
	static var error: Self { .invalid }
	static var empty: Self { .blank }
	static var start: Self { .bRook }
	static func flip(_ x: ChessPieces) -> ChessPieces { x }
}

struct ChessBoard: Board {
	typealias E = ChessPieces
	
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
	
	// Movement functions for Chess inspired by SHCChess demo
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
	
	// Placement of Chess pieces along with opponent flipping
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

@Observable final class ChessGame: Game {
	typealias E = ChessPieces
	
	let name = "Chess"
	var board: ChessBoard
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
	
	let errorPiece = ChessPieces.invalid
	
	var player1Score: Int { score(for: player1) }
	var player2Score: Int { score(for: player1) }
	
	var whitePiece: ChessPieces { E.wPawn }
	var blackPiece: ChessPieces { E.bPawn }
	
	var gameIsOver: Bool {
		false
	}
	
	let moves: [ChessPieces : [NavigationFunction]] = {
		[.wPawn:
			[
				{ pos in pos.row -= 1 }, // move up 1 square
				{ pos in pos.row -= 2 }, // move up 2 squares
			],
		 .bPawn:
			 [
				 { pos in pos.row += 1 }, // move down 1 square
				 { pos in pos.row += 2 }, // move down 2 squares
			 ],
		]
	}()
	
	/// Convenience getters
	var rows: Int    { board.rows }
	var columns: Int { board.columns }
	
	init(rows: Int = 8, columns: Int = 8) {
		let player1 = Player(name: "Dummy1", colour: .white)
		self.board = ChessBoard(rows: rows, columns: columns)
		self.player1 = player1
		self.player2 = Player(name: "Dummy2", colour: .white)
		self.activePlayer = player1
		setupInitialPieces()
	}
	
	func score(for player: Player) -> Int {
		board.score(player.colour)
	}
	
	func newGame() {
		self.board = ChessBoard(rows: rows, columns: columns)
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
		guard let selectedPiece else { return false }
		
		// check moves in each direction
		let piece = self[selectedPiece]
//		for moves in moves[piece] {
//			
//		}
	
		return false
	}

	func setupInitialPieces() {
		board.move(to: Position(row: 0, col: 0), for: .bRook)
		board.move(to: Position(row: 0, col: 1), for: .bKnight)
		board.move(to: Position(row: 0, col: 2), for: .bBishop)
		board.move(to: Position(row: 0, col: 3), for: .bKing)
		board.move(to: Position(row: 0, col: 4), for: .bQueen)
		board.move(to: Position(row: 0, col: 5), for: .bBishop)
		board.move(to: Position(row: 0, col: 6), for: .bKnight)
		board.move(to: Position(row: 0, col: 7), for: .bRook)
		board.move(to: Position(row: 7, col: 0), for: .wRook)
		board.move(to: Position(row: 7, col: 1), for: .wKnight)
		board.move(to: Position(row: 7, col: 2), for: .wBishop)
		board.move(to: Position(row: 7, col: 3), for: .wKing)
		board.move(to: Position(row: 7, col: 4), for: .wQueen)
		board.move(to: Position(row: 7, col: 5), for: .wBishop)
		board.move(to: Position(row: 7, col: 6), for: .wKnight)
		board.move(to: Position(row: 7, col: 7), for: .wRook)
		for i in 0...7 {
			board.move(to: Position(row: 1, col: i), for: .bPawn)
			board.move(to: Position(row: 6, col: i), for: .wPawn)
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
		} else if let selectedPiece, selected == selectedPiece {
			// undo the selection
			self.selectedPiece = nil
			return
		} else if let selectedPiece, board[selected] != .empty {
			// pick another piece
			self.selectedPiece = selected
			return
		}
		if setPiece(selected) {
			saveGame() // all is ok
		} else {
			// invalid move
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
            if let board = try? JSONDecoder().decode(ChessBoard.self, from: data) {
				self.board = board
                return
            }
        }
		self.board = ChessBoard(rows: rows, columns: columns)
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



