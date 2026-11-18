//
//  Game.swift
//  MGBoardGames
//
//  Created by Michael Griebling on 08.11.2026.
//

import Foundation

// Generic game class
protocol Game: AnyObject {
	associatedtype E: GamePieceEnum

	var name: String { get }
	var activePlayer: Player { get }
	var player1: Player { get set }
	var player2: Player { get set }
	var player1Score: Int { get }
	var player2Score: Int { get }
	var activeColor: E.Enum { get }
	var gameIsOver: Bool { get }
	var isDraw: Bool { get }
	var rows: Int { get }
	var columns: Int { get }
	
	init(rows: Int, columns: Int)
	func color(for player: Player) -> E.Enum
	func set(player1: Player, player2: Player)
	func score(for player: Player) -> Int
	func canPlayerMakeMove(_ player: Player) -> Bool
	func setupInitialPieces()
	func validMoves(for player: Player) -> [Position]
	func makeNextMove()
	func isValidMove(to position: Position, for player: Player) -> Bool
	func newGame()
	func saveGame()
	
	subscript(position: Position) -> E.Enum { get set }
}

extension Game {
	
	func set(player1: Player, player2: Player) {
		self.player1 = player1
		self.player2 = player2
	}
}
