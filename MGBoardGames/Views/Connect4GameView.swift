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
	
	@State private var drop = false

	var body: some View {
		let initialBallHeight = -500.0
		VStack {
			Spacer(minLength: 0)
			SquareBoardView(board: game.board, lightColor: Color(.systemBlue), darkColor: Color(.systemBlue), boardColor: Color.yellow, lineColor: Color.clear, useCutOut: true, doTap: game.handleTap) { piece, position, drop in
				pieceView(piece: piece, position: position)
					.offset(y: drop ? initialBallHeight : 0)
					.animation(.easeIn(duration: 0.5), value: drop)
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
		.scaleEffect(2.1)
		.shadow(color: .black.opacity(0.5), radius: 2, x:0, y:0)
	}
}

#Preview {
	let game = Connect4Game()
	Connect4GameView(game: game, showMoves: false)
}
