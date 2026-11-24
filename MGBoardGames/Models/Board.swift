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
	
	/// convenience method
	func inc(_ row: Int = 0, col: Int = 0) -> Position {
		Position(row: self.row + row, col: self.col + col)
	}
	
	func inc(_ move: NavigationFunction, times n: Int = 1) -> Position {
		var pos = self  			  // make this mutable
		for _ in 1...n { move(&pos) } // move n times
		return pos
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

typealias NavigationFunction = (inout Position) -> ()

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


