//
//  GamePiece.swift
//  MGBoardGames
//
//  Created by Michael Griebling on 07.11.2026.
//

import Foundation

struct Position: Codable, Hashable, Equatable {
	let row: Int
	let col: Int
}

protocol GamePieceEnum : CustomStringConvertible, Codable, RawRepresentable {
	associatedtype Enum: Codable, Equatable
	static var empty: Enum { get }
	static var error: Enum { get }
	static var start: Enum { get }
	
	static func flip(_ x: Enum) -> Enum
}

/// EXAMPLE ONLY - PLEASE REPLACE WITH ACTUAL GAME PIECES
//enum TicTacToePieces: Int, GamePieceEnum {
//	case blank = 0, fail, blackPiece, whitePiece
//	
//	var description: String {
//		switch self {
//			case .blackPiece: "X"
//			case .whitePiece: "O"
//			case .fail: 	  "🚫"
//			default:          " "
//		}
//	}
//	
//	static var empty: Self { .blank }
//	static var error: Self { .fail }
//	static var start: Self { .blackPiece }
//	
//	static func flip(_ x: TicTacToePieces) -> TicTacToePieces {
//		x  // no function for tic-tac-toe
//	}
//}

struct GameBoard<E: GamePieceEnum>: Codable {
	let rows: Int
	let columns: Int
	var activeColor = E.start
	
	// A dictionary mapping positions to pieces makes lookup and movement highly efficient
	var pieces: [Position: E.Enum] = [:]
	
	init(rows: Int, columns: Int) {
		self.rows = rows
		self.columns = columns
	}
	
	mutating func clear(_ coordinate: Position) {
		pieces.removeValue(forKey: coordinate)
	}
	
	subscript(_ position: Position) -> E.Enum {
		get { pieces[position, default: E.empty] }
		set { pieces[position] = newValue }
	}
	
	// Helper to check if a coordinate is within board boundaries
	func isValid(coordinate: Position) -> Bool {
		coordinate.row >= 0 && coordinate.row < rows &&
		coordinate.col >= 0 && coordinate.col < columns
	}
}


