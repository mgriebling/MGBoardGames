//
//  ChessGame.swift
//  MGChess
//
//  Created by Mike Griebling on 2021-09-10.
//

import SwiftUI

enum ChessPieces: GamePieceEnum {
	static let boardSize = 8   // this should probably not be hardcoded here
	
	case blank, invalid
	case king(PlayerColor), queen(PlayerColor), bishop(PlayerColor)
	case knight(PlayerColor), rook(PlayerColor), pawn(PlayerColor, Bool)
	
	var color: PlayerColor? {
		switch self {
		case let .queen(color),
			 let .king(color),
			 let .bishop(color),
			 let .knight(color),
			 let .rook(color):
			return color
		case let .pawn(color, _):
			return color
		default:
			return nil
		}
	}

	var isWhite: Bool { color == .white }
	var isBlack: Bool { color == .black }
	var isEmpty: Bool { self == .blank }
	
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
	
	private func generateMoves(for moveGenerator: (Int) -> ([NavigationFunction]), distance: Int) -> [NavigationFunction] {
		var moves = [NavigationFunction]()
		for d in 1...distance {
			moves.append(contentsOf: moveGenerator(d))
		}
		return moves
	}
	
	private func allMoves(d: Int) -> [NavigationFunction] {
		orthogonalMoves(d: d) + diagonalMoves(d: d)
	}
	
	private func orthogonalMoves(d: Int) -> [NavigationFunction] {
		[
			{ pos in pos.col += d },               // move right
			{ pos in pos.col -= d },               // move left
			{ pos in pos.row -= d },               // move up
			{ pos in pos.row += d },               // move down
		]
	}
	
	private func diagonalMoves(d: Int) -> [NavigationFunction] {
		[
			{ pos in pos.row += d; pos.col += d }, // move right up
			{ pos in pos.row -= d; pos.col += d }, // move right down
			{ pos in pos.row += d; pos.col -= d }, // move left up
			{ pos in pos.row -= d; pos.col -= d }  // move left down
		]
	}
	
	private func knightMoves() -> [NavigationFunction] {
		[
			{ pos in pos.row += 2; pos.col += 1 }, // up 2, right 1
			{ pos in pos.row += 2; pos.col -= 1 }, // up 2, left 1
			{ pos in pos.row -= 2; pos.col += 1 }, // down 2, right 1
			{ pos in pos.row -= 2; pos.col -= 1 }, // down 2, left 1
			{ pos in pos.row -= 1; pos.col += 2 }, // right 2, down 1
			{ pos in pos.row += 1; pos.col += 2 }, // right 2, up 1
			{ pos in pos.row -= 1; pos.col -= 2 }, // left 2, down 1
			{ pos in pos.row += 1; pos.col -= 2 }, // left 2, up 1
		]
	}
	
	private func pawnMoves(_ color: PlayerColor, _ first: Bool) -> [NavigationFunction] {
		// assumes white is on the bottom of the board
		let d = color == .white ? 1 : -1
		var moves: [NavigationFunction] = [
			{ pos in pos.row -= d; pos.col += 1 }, // move vertically/right
			{ pos in pos.row -= d; pos.col -= 1 }, // move vertically/left
			{ pos in pos.row -= d },               // move vertically 1 row
			{ pos in pos.row -= 2 * d },           // move vertically 2 rows
		]
		if !first { moves.removeLast() }		   // remove 2 row move
		return moves
	}
	
	var moves: [NavigationFunction] {
		let maxMoves = Self.boardSize
		switch self {
			case .king:
				return allMoves(d: 1)
			case .queen:
				return generateMoves(for: allMoves, distance: maxMoves)
			case .bishop:
				return generateMoves(for: diagonalMoves, distance: maxMoves)
			case .rook:
				return generateMoves(for: orthogonalMoves, distance: maxMoves)
			case .knight:
				return knightMoves()
			case .pawn(let color, let first):
				return pawnMoves(color, first)
			default:
				return [NavigationFunction]()
		}
	}
	
	static var error: Self { .invalid }
	static var empty: Self { .blank }
	static var start: PlayerColor { .black }
	
	// piece name aliases
	static var wKing: Self { .king(.white) }
	static var wQueen: Self { .queen(.white) }
	static var wBishop: Self { .bishop(.white) }
	static var wKnight: Self { .knight(.white) }
	static var wRook: Self { .rook(.white) }
	static var wCastle: Self { .rook(.white) }
	static var wPawn: Self { .pawn(.white, true) }
	static var bKing: Self { .king(.black) }
	static var bQueen: Self { .queen(.black) }
	static var bBishop: Self { .bishop(.black) }
	static var bKnight: Self { .knight(.black) }
	static var bRook: Self { .rook(.black) }
	static var bCastle: Self { .rook(.black) }
	static var bPawn: Self { .pawn(.black, true) }
}

struct ChessBoard: Board {
	typealias E = ChessPieces
	
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

	var player1Score: Int { score(for: player1) }
	var player2Score: Int { score(for: player1) }
	
	var gameIsOver: Bool {
		false
	}
	
	/// Convenience getters
	var rows: Int    { board.rows }
	var columns: Int { board.columns }
	
	init() {
		let player1 = Player(name: "Dummy1", colour: .white)
		self.board = ChessBoard()
		self.player1 = player1
		self.player2 = Player(name: "Dummy2", colour: .white)
		self.activePlayer = player1
		setupInitialPieces()
	}
	
	func score(for player: Player) -> Int {
		board.score(player.colour)
	}
	
	func newGame() {
		self.board = ChessBoard()
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
		if activePlayer == player1 {
			activePlayer = player2
		} else {
			activePlayer = player1
		}
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
		for move in piece.moves {
			var toLocation = selectedPiece
			move(&toLocation)
			if selected == toLocation { return true	}
		}
		return false
	}

	func setupInitialPieces() {
		self[Position(row: 0, col: 0)] = .bRook
		self[Position(row: 0, col: 1)] = .bKnight
		self[Position(row: 0, col: 2)] = .bBishop
		self[Position(row: 0, col: 3)] = .bKing
		self[Position(row: 0, col: 4)] = .bQueen
		self[Position(row: 0, col: 5)] = .bBishop
		self[Position(row: 0, col: 6)] = .bKnight
		self[Position(row: 0, col: 7)] = .bRook
		self[Position(row: 7, col: 0)] = .wRook
		self[Position(row: 7, col: 1)] = .wKnight
		self[Position(row: 7, col: 2)] = .wBishop
		self[Position(row: 7, col: 3)] = .wKing
		self[Position(row: 7, col: 4)] = .wQueen
		self[Position(row: 7, col: 5)] = .wBishop
		self[Position(row: 7, col: 6)] = .wKnight
		self[Position(row: 7, col: 7)] = .wRook
		for i in 0...7 {
			self[Position(row: 1, col: i)] = .bPawn
			self[Position(row: 6, col: i)] = .wPawn
		}
	}
	
	func canPlayerMakeMove(_ player: Player) -> Bool {
		for row in 0..<rows {
			for column in 0..<columns {
				if isValidMove(to: Position(row: row, col: column), for: player) { return true }
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
            if let board = try? JSONDecoder().decode(ChessBoard.self, from: data) {
				self.board = board
                return
            }
        }
		self.board = ChessBoard()
    }
    
	func setPiece(_ selected: Position) -> Bool {
		if isValidMove(to: selected, for: activePlayer) {
			guard let selectedPiece else { return false }
			var activePiece = self[selectedPiece]
//			if case let .pawn(color, first) = activePiece, first {
//				activePiece = .pawn(color, false)  // first move is used
//			}
			self[selectedPiece] = .empty
			self.selectedPiece = nil
			print("Moving \(activePiece) to \(selected)")
			self[selected] = activePiece
			print("Board at \(selected) = \(self[selected])")
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



