//
//  GamePiece.swift
//  MGBoardGames
//
//  Created by Michael Griebling on 07.11.2026.
//

import Foundation

struct Position: Codable, Hashable, Equatable {
	var row: Int
	var col: Int
	var maxRows: Int
	var maxCols: Int
	
	init(row: Int = 0, col: Int = 0) {
		self.row = row
		self.col = col
		self.maxCols = 8
		self.maxRows = 8
	}
	
	mutating func setMax(rows: Int, columns: Int) {
		self.maxRows = rows
		self.maxCols = columns
	}
	
	func name(maxRows: Int) -> String {
		let aCode = Int(Character("a").asciiValue!)
		return String(UnicodeScalar(aCode+col)!) + String(maxRows-row)
	}
	
	/// convenience method
	func inc(_ row: Int = 0, col: Int = 0) -> Position {
		Position(row: self.row + row, col: self.col + col)
	}
	
	func inc(_ move: NavigationFunction, times n: Int = 1) -> Position {
		var pos = self  			  // make this mutable
		for _ in 1...n { move.move(&pos) } // move n times
		return pos
	}
	
	static func - (lhs: Self, rhs: Self) -> Position {
		Position(row: lhs.row - rhs.row, col: lhs.col - rhs.col)
	}
}

protocol GamePieceEnum : Codable, Equatable, Hashable {
	associatedtype Enum: Codable, Equatable, Hashable
	static var empty: Enum { get }
	static var error: Enum { get }
	static var start: PlayerColor { get }
	
	var isWhite: Bool { get }
	var isBlack: Bool { get }
	var isEmpty: Bool { get }
}

// typealias NavigationFunction = (inout Position) -> ()
struct NavigationFunction {
	var direction: Direction = .rightUp
	var row: Int = 1
	var col: Int = 1
	
	init(row: Int = 0, col: Int = 0) {
		self.row = row
		self.col = col
		self.direction = detectLocation(row: row, col: col)
	}
	
	func detectLocation(row: Int, col: Int) -> Direction {
		if col == 0 {
			if row == 0 { return .noMove }
			return row > 0 ? .down : .up
		}
		if row == 0 {
			return col > 0 ? .right : .left
		}
		
		if col > 0 {
			return row > 0 ? .rightDown : .rightUp
		} else {
			return row > 0 ? .leftDown : .leftUp
		}
	}
	
	func move(_ pos: inout Position) {
		pos.row += row
		pos.col += col
	}
	
	enum Direction {
		case noMove
		case left, right, up, down
		case leftUp, leftDown, rightUp, rightDown
	}
}

protocol Board: Codable {
	associatedtype E: GamePieceEnum
	
	var rows: Int { get }
	var columns: Int { get }
	var itemsInARow: Int { get }
	
	mutating func clear(_ position: Position)
	mutating func set(positions: [Position], to piece: E.Enum)
	mutating func clearAll()
	
	subscript(_ position: Position) -> E.Enum { get set }
}


