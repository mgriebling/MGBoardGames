//
//  Connect4GameView.swift
//  MGBoardGames
//
//  Created by Michael Griebling on 06.11.2026.
//

import SwiftUI

struct Connect4GameView: View {
	let game: Connect4Game
	let showMoves: Bool

	var body: some View {
		VStack {
			Spacer(minLength: 0)
			SquareBoardView(board: game.board, lightColor: Color(.systemBlue), darkColor: Color(.systemBlue), boardColor: Color.yellow, lineColor: Color.clear, useCutOut: true, doTap: game.handleTap) { piece, position in
				pieceView(piece: piece, position: position)
			}
			.blur(radius: game.gameIsOver ? 3 : 0)
			Spacer(minLength: 0)
		}
	}
	
	func pieceView(piece: Connect4Pieces, position: Position) -> some View {
		Group {
			if piece == Connect4Pieces.empty {
				if showMoves && game.isValidMove(to: position, for: game.activePlayer) {
					Image(systemName: "checkmark.circle")
						.foregroundColor(game.activePlayer.colour == .white ? Color.white : .black)
						.opacity(0.5)
				} else {
					Text(" ")
				}
			} else {
				Text(piece.description)
			}
		}
		.scaleEffect(2.2)
		.shadow(color: .black.opacity(0.5), radius: 2, x:2, y:2)
	}
}

#Preview {
	let game = Connect4Game()
	Connect4GameView(game: game, showMoves: false)
}
