//
//  ReversiGameView.swift
//  MGBoardGames
//
//  Created by Michael Griebling on 06.11.2026.
//

import SwiftUI

struct ReversiGameView: View {
	let game: ReversiGame
	let showMoves: Bool

	var body: some View {
		VStack {
			Spacer(minLength: 0)
			SquareBoardView(board: game.board, lightColor: Color.backColour, darkColor: Color.backColour, doTap: game.handleTap) { piece, position, _ in
				pieceView(piece: piece, position: position)
			}
			.blur(radius: game.gameIsOver ? 3 : 0)
			Spacer(minLength: 0)
		}
	}
	
	@ViewBuilder
	func pieceView(piece: ReversiPieces, position: Position) -> some View {
		Group {
			if piece == ReversiPieces.empty {
				if showMoves && game.isValidMove(to: position, for: game.activePlayer) {
					Image(systemName: "checkmark.circle")
						.foregroundColor(game.activeColor == .white ? Color.white : .black)
						.opacity(0.5)
				} else {
					Text(piece.description)
				}
			} else {
				Text(piece.description)
			}
		}
		.scaleEffect(1.9)
		.shadow(color: .black.opacity(0.5), radius: 2, x:2, y:2)
	}
}

#Preview {
	let game = ReversiGame()
	ReversiGameView(game: game, showMoves: false)
}
