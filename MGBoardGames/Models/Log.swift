//
//  Log.swift
//  MGBoardGames
//
//  Created by Michael Griebling on 25.11.2026.
//

import Foundation

struct Log: Codable {
	private var moves = [Position]()
	
	mutating func add(move: Position) {
		moves.append(move)
	}
}
