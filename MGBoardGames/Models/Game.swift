//
//  Game.swift
//  MGBoardGames
//
//  Created by Michael Griebling on 08.11.2026.
//

import Foundation

// Generic game class
protocol Game {
	associatedtype E: GamePieceEnum
	
	var name: String { get }
	// var board: any Board { get }
	var activePlayer: Player { get }
	var gameIsOver: Bool { get }
	var rows: Int { get }
	var columns: Int { get }
	
	init(rows: Int, columns: Int, player1: Player, player2: Player)
	func canPlayerMakeMove(_ player: Player) -> Bool
	func setupInitialPieces()
	func validMoves(for player: Player) -> [Position]
	func makeNextMove()
	func isValidMove(to position: Position, for player: Player) -> Bool
	
	subscript(position: Position) -> E.Enum { get set }
}
