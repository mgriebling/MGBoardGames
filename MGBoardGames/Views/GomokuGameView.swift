//
//  ReversiGameView.swift
//  MGBoardGames
//
//  Created by Michael Griebling on 06.11.2026.
//

import SwiftUI

struct GomokuGameView: View {
	let game: GomokuGame
	let boardWidth: CGFloat
	let showMoves: Bool

	var body: some View {
		VStack {
			Spacer(minLength: 0)
			SquareBoardView(board: game.board, lightColor: .clear,
							darkColor: .clear, boardColor: .clear,
							lineColor: .clear, doTap: game.handleTap) { piece, position, _ in
				pieceView(piece: piece, position: position)
			}
			.background(GomokuView(width: boardWidth))
			.blur(radius: game.gameIsOver ? 3 : 0)
			Spacer(minLength: 0)
		}
	}
	
	@ViewBuilder
	func GomokuView(width: CGFloat) -> some View {
		let goSize = game.columns == 19
		let increment = width / CGFloat(game.columns+1)
		let thickness = 1.0
		let dotSize = 6.0
		let dotSpacing = increment * (goSize ? 6 : 4)
		let dotStart = increment * 4
		let lineLength = width-CGFloat(2*increment)
		let halfField = width/2
		let lineColor = Color.black
		let radius = 10.0
		
		Rectangle().fill(Color.backColour)
			.clipShape(RoundedRectangle(cornerRadius: radius))
		
		// draw horizontal lines
		ForEach(1...game.columns, id:\.self) { col in
			Rectangle()
				.foregroundStyle(lineColor)
				.frame(width: lineLength, height: thickness)
				.position(x: halfField, y: CGFloat(col)*increment)
		}
		
		// draw vertical lines
		ForEach(1...game.rows, id:\.self) { row in
			Rectangle()
				.foregroundStyle(lineColor)
				.frame(width: thickness, height: lineLength)
				.position(x: CGFloat(row)*increment, y: halfField)
		}
		
		// draw dots at intersection points
		ForEach(0..<3, id: \.self) { vdot in
			ForEach(0..<3, id: \.self) { dot in
				if goSize || vdot == dot || vdot == (dot-2) || (vdot-2) == dot {
					Circle()
						.foregroundStyle(lineColor)
						.frame(width: dotSize, height: dotSize)
						.position(x: dotStart + CGFloat(dot)*dotSpacing,
								  y: dotStart + CGFloat(vdot)*dotSpacing)
				}
			}
		}
	}
	
	@ViewBuilder
	func pieceView(piece: GomokuPieces, position: Position) -> some View {
		Group {
			if piece == GomokuPieces.empty {
				if showMoves && game.isValidMove(to: position, for: game.activePlayer) {
					Image(systemName: "checkmark.circle")
						.foregroundColor(game.activePiece.isWhite ? Color.white : .black)
						.opacity(0.5)
				} else {
					Text(piece.description)
				}
			} else {
				Text(piece.description)
			}
		}
		.shadow(color: .black.opacity(0.5), radius: 2, x:2, y:2)
	}
}

#Preview {
	let game = GomokuGame()
	GomokuGameView(game: game, boardWidth: 402, showMoves: false)
}
