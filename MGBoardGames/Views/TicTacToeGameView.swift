//
//  TicTacToeGameView.swift
//  MGBoardGames
//
//  Created by Michael Griebling on 06.11.2026.
//

import SwiftUI

struct TicTacToeGameView: View {
	let game: TicTacToeGame
	let showMoves: Bool
	
	@State private var fontSize = CGFloat(50)
	
	var body: some View {
		VStack {
			Spacer(minLength: 0)
			SquareBoardView(board: game.board, lightColor: Color.backColour, darkColor: Color.backColour, lineColor: .black, lineWidth: 5, doTap: game.handleTap) { piece, position, _ in
				pieceView(piece: piece, position: position)
			}
			.blur(radius: game.gameIsOver ? 3 : 0)
			Spacer(minLength: 0)
		}
	}
	
	@ViewBuilder
	func pieceView(piece: TicTacToePieces, position: Position) -> some View {
		let size = 2.5 * fontSize
		let pieceColor = Color(.black)
		Group {
			if piece == TicTacToePieces.empty {
				if showMoves && game.isValidMove(to: position, for: game.activePlayer) {
					let name = game.activePiece.isBlack ? "x.circle" : "o.circle"
					Image(systemName: name)
						.font(.system(size: size, weight: .heavy, design: .rounded))
						.foregroundStyle(pieceColor)
						.opacity(0.7)
				}
			} else {
				Image(systemName: piece.description)
					.font(.system(size: size, weight: .heavy, design: .rounded))
					.foregroundStyle(pieceColor)
			}
		}
		.scaleEffect(piece.isBlack ? 0.9 : 0.8)
		.shadow(color: .black.opacity(0.5), radius: 2, x:2, y:2)
	}
}

#Preview {
	let game = TicTacToeGame()
	TicTacToeGameView(game: game, showMoves: false)
}
