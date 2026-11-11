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
	var board: GameBoard<E> { get }
	var activePlayer: Player { get }
	var gameIsOver: Bool { get }
	var rows: Int { get }
	var columns: Int { get }
	
	init(rows: Int, columns: Int, player1: Player, player2: Player)
	func canPlayerMakeMove(_ player: Player) -> Bool
	func setupInitialPieces()
	func gameStateChanged()
	func validMoves(for player: Player) -> [BoardCoordinate]
	func makeNextMove()
	func isValidMove(to position: BoardCoordinate, for player: Player) -> Bool
	
	subscript(row: Int, column: Int) -> E.Enum { get set }
	subscript(position: BoardCoordinate) -> E.Enum { get set }

}
