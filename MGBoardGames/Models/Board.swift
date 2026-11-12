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
}

protocol GamePieceEnum : CustomStringConvertible, Codable, RawRepresentable {
	associatedtype Enum: Codable, Equatable
	static var empty: Enum { get }
	static var error: Enum { get }
	static var start: Enum { get }
	
	var isWhite: Bool { get }
	var isBlack: Bool { get }
	var isEmpty: Bool { get }
}

typealias NavigationFunction = (inout Position) -> ()

protocol Board: Codable {
	associatedtype E: GamePieceEnum
	
	var rows: Int { get }
	var columns: Int { get }
	
	init(rows: Int, columns: Int)
	
	mutating func clear(_ position: Position)
	mutating func set(positions: [Position], to piece: E.Enum)
	mutating func clearAll()
	
	subscript(_ position: Position) -> E.Enum { get set }
}


