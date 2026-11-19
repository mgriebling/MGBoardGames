//
//  ChessGameView.swift
//  MGBoardGames
//
//  Created by Michael Griebling on 06.11.2026.
//

import SwiftUI

struct ChessGameView: View {
	let game: ChessGame
	let showMoves: Bool
	
	@State private var fontSize = CGFloat(50)
	
	var body: some View {
		VStack {
			Spacer(minLength: 0)
			SquareBoardView(board: game.board, doTap: game.handleTap) { piece, position in
				pieceView(piece: piece, position: position)
			}
			.blur(radius: game.gameIsOver ? 3 : 0)
			Spacer(minLength: 0)
		}
	}
	
	@ViewBuilder
	func pieceView(piece: ChessPieces, position: Position) -> some View {
		let selected = position == game.selectedPiece
		Group {
			if piece == ChessPieces.empty {
				if showMoves && game.isValidMove(to: position, for: game.activePlayer) {
					Image(systemName: "checkmark.circle")
						.foregroundColor(game.activePlayer.colour == .white ? Color.white : .black)
						.opacity(0.5)
				} else {
					Image(systemName: piece.description)
				}
			} else {
				Image(piece.image)
					.resizable()
					.aspectRatio(contentMode: .fit)
			}
		}
		.scaleEffect(0.9)
		.shadow(color: .black.opacity(0.5), radius: 2, x:2, y:2)
		.background {
			RoundedRectangle(cornerRadius: 10)
				.inset(by: -2)
				.fill(Color(.systemBlue).opacity(selected ? 1 : 0))
		}
	}
}

#Preview {
	let game = ChessGame()
	ChessGameView(game: game, showMoves: false)
}
