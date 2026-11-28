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
	
	@State private var move = false
	
	var body: some View {
		VStack {
			Spacer(minLength: 0)
			SquareBoardView(board: game.board, selection: game.selectedPiece, doTap: game.handleTap) { piece, position, _ in
				pieceView(piece: piece, position: position)
			}
			.blur(radius: game.gameIsOver ? 3 : 0)
			Spacer(minLength: 0)
		}
	}
	
	@ViewBuilder
	func pieceView(piece: ChessPieces, position: Position) -> some View {
		Group {
			if piece.isEmpty {
				if showMoves && game.isValidMove(to: position, for: game.activePlayer) {
					Image(systemName: "checkmark.circle")
						.foregroundColor(game.activePlayer.colour == .white ? Color.white : .black)
						.opacity(0.5)
				} else {
					Image(piece.image)
						.resizable()
						.aspectRatio(contentMode: .fit)
				}
			} else {
				Image(piece.image)
					.resizable()
					.offset(x: 0, y: move ? -2 : 0)
					.aspectRatio(contentMode: .fit)
			}
		}
		.scaleEffect(0.9)
		.shadow(color: .black.opacity(0.5), radius: 2, x:2, y:2)
	}
}

#Preview {
	@Previewable @State var game = ChessGame()
	ChessGameView(game: game, showMoves: false)
}
