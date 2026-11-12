//
//  GameList.swift
//  MGBoardGames
//
//  Created by Michael Griebling on 07.11.2026.
//

import Foundation
import SwiftUI

enum GameList : Codable, CaseIterable, Identifiable {

	case reversi, go, mill, tictactoe, connectfour, gomoku, chess, checkers
	
	var name: String {
		switch self {
			case .reversi: 		"Reversi"
			case .go: 			"Go"
			case .mill: 		"Mill"
			case .tictactoe: 	"Tic-Tac-Toe"
			case .connectfour: 	"Connect Four"
			case .gomoku: 		"Gomoku"
			case .chess: 		"Chess"
			case .checkers: 	"Checkers"
		}
	}
	
	var image: ImageResource {
		switch self {
			case .reversi: 		.reversi
			case .go: 			.reversi
			case .mill: 		.reversi
			case .tictactoe: 	.tictactoe
			case .connectfour: 	.reversi
			case .gomoku: 		.reversi
			case .chess: 		.reversi
			case .checkers: 	.reversi
		}
	}
	
	var id: Self { self }
}
