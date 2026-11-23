//
//  Select4Game.swift
//  MGBoardGames
//
//  Created by Mike Griebling on 2026-09-10.
//

import Foundation

enum Connect4Pieces: GamePieceEnum  {
	case invalid, blank
	case piece(PlayerColor)
	
	var isWhite: Bool { self == .piece(.white) }
	var isBlack: Bool { self == .piece(.black) }
	var isEmpty: Bool { self == .blank }
	
	var description: String {
		switch self {
			case .invalid:	     "🚫"
			case .piece(.black): "🔴"
			case .piece(.white): "🟡"
			default:             ""
		}
	}
	
	static var error: Self { .invalid }
	static var empty: Self { .blank }
	static var start: PlayerColor { .black }
}

struct Connect4Board: Board {
	typealias E = Connect4Pieces
	
	let rows: Int = 6
	let columns: Int = 7
	let itemsInARow: Int = 4
	
	var winCount = 0
	
	private static let MAX_SCORE = 1_000_000_000_000
	private static let SEMI_OPEN_SCORE = [0, 1, 100, 10_000, 1_000_000, 100_000_000]
	private static let FULL_OPEN_SCORE = [0, 10, 1_000, 100_000, 10_000_000, 1_000_000_000]
	
	/// Game board with rows x columns positions
	private var pieces = [E]()
	
	init() {
		clearAll()
	}
	
	mutating func clear(_ position: Position) { self[position] = E.blank }
	
	mutating func clearAll() {
		pieces = Array(repeating: E.empty, count: rows * columns)
	}

	// Placement of Connect4 pieces
	mutating func move(to position: Position, for activeColor: E.Enum) {
		self[position] = activeColor
	}
	
	func score(for playerColor: PlayerColor) -> Int {
		var score = 0
		
		for x in 0..<columns {
			// vertical
			score += getScore(x, 0, 0, 1);
			
			// diagonal top side going down/right
			score += getScore(x, 0, 1, 1);

			// diagonal bottom side going up/right
			score += getScore(x, rows-1, 1, -1);
		}

		for y in 0..<rows {
			// horizontal
			score += getScore(0, y, 1, 0)
	
			if y > 0 && y < rows-1 {
				// diagonal left side going down/right
				score += getScore(0, y, 1, 1)

				// diagonal left side going up/right
				score += getScore(0, y, 1, -1)
			}
		}
		
		return score
	}
	
	private func getScore(_ x:Int, _ y:Int, _ deltaX:Int, _ deltaY:Int) -> Int {
		var score = 0
		var x = x
		var y = y
		
		var leftOpen = false
		var position : E
		var lastPosition : E? = nil
		var whiteCount = 0
		var blackCount = 0
		
		while x >= 0 && x < columns && y >= 0 && y < rows {
			position = self[Position(row: y, col: x)]
			switch position {
				case .piece(.black):
					if let lastPosition, lastPosition == .piece(.white) {
						leftOpen = false
					} else if let lastPosition, lastPosition == E.blank {
						leftOpen = true
					}
					score -= calculateScore(blackCount, leftOpen, false)
					blackCount = 0
					whiteCount += 1
				case .piece(.white):
					if let lastPosition, lastPosition == .piece(.black) {
						leftOpen = false
					} else if let lastPosition, lastPosition == E.blank {
						leftOpen = true
					}
					score += calculateScore(whiteCount, leftOpen, false)
					whiteCount = 0
					blackCount += 1
				case .blank:
					score -= calculateScore(blackCount, leftOpen, true)
					score += calculateScore(whiteCount, leftOpen, true)
					whiteCount = 0
					blackCount = 0
				default: break
			}
			
			x += deltaX
			y += deltaY
			
			lastPosition = position
		}
		
		score -= calculateScore(blackCount, leftOpen, false)
		score += calculateScore(whiteCount, leftOpen, false)
		
		return score;
	}
	
	private func calculateScore(_ count:Int, _ leftOpen:Bool, _ rightOpen:Bool) -> Int {
		if count >= winCount {
			return Self.MAX_SCORE
		}
		if !leftOpen && !rightOpen {
			return 0
		}
		
		if leftOpen && rightOpen {
			return Self.FULL_OPEN_SCORE[count]
		}
		return Self.SEMI_OPEN_SCORE[count]
	}
	
	func isFull() -> Bool {
		pieces.count { $0 == .blank } == 0
	}
	
	func squaresMatch(initialChip: E, pos: Position, move: NavigationFunction) -> Bool {
		/// bail out early if we can't win from here
		/// checks end pos for on-board coordinates
		let endPos = pos.inc(move, times: itemsInARow-1)
		if endPos.row < 0 || endPos.row >= rows { return false }
		if endPos.col < 0 || endPos.col >= columns  { return false }
		
		/// now we need to check all positions in the *move* direction
		var pos = pos  // mutatble
		for _ in 1..<itemsInARow {
			move(&pos)
			if self[pos] != initialChip { return false }
		}
		return true
	}
	
	private let moves: [NavigationFunction] = [
		{pos in pos.col += 1 }, 			  // check to the right
		{pos in pos.row += 1 },			 	  // check below
		{pos in pos.row += 1; pos.col += 1 }, // diagonal down, right
		{pos in pos.row -= 1; pos.col += 1 }  // diagonal up, right
	]
	
	func isWin(for player: Player) -> Bool {
		let chip = E.piece(player.colour)
		
		for row in 0..<rows {
			for col in 0..<columns {
				let pos = Position(row: row, col: col)
				for move in moves {
					if squaresMatch(initialChip: chip, pos: pos, move: move) {
						return true
					}
				}
			}
		}
		return false
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
		// don't decode anything else
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
	
	var whitePiece: Connect4Pieces { .piece(.white) }
	var blackPiece: Connect4Pieces { .piece(.black) }
	
	var gameIsOver: Bool {
		false
	}
	
	let moves: [NavigationFunction] = []
	
	/// Convenience getters
	var rows: Int    { board.rows }
	var columns: Int { board.columns }
	
	init() {
		let player1 = Player(name: "Dummy1", colour: .white)
		self.board = Connect4Board()
		self.player1 = player1
		self.player2 = Player(name: "Dummy2", colour: .white)
		self.activePlayer = player1
		setupInitialPieces()
	}
	
	func score(for player: Player) -> Int {
		board.score(for: player.colour)
	}
	
	func newGame() {
		self.board = Connect4Board()
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
			let scoreForMove = testBoard.score(for: activeColor)
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
		// Board is initially clear
	}
	
	func canPlayerMakeMove(_ state: Player) -> Bool {
		return true
	}
	
	func handleTap(at selected: Position) {
		guard !gameIsOver else { return }
		// determine the next row for this column
		let row = countPieces(col: selected.col)
		if setPiece(Position(row: rows - 1 - row, col: selected.col)) {
			saveGame() // all is ok
		} else {
			// invalid move
			print("Invalid move...")
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
            if let board = try? JSONDecoder().decode(Connect4Board.self, from: data) {
				self.board = board
                return
            }
        }
		self.board = Connect4Board()
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



