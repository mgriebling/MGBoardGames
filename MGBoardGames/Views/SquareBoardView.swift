//
//  ReversiGameView.swift
//  MGBoardGames
//
//  Created by Michael Griebling on 06.11.2026.
//

import SwiftUI

struct SquareBoardView<Item: GamePieceEnum, ItemView: View>: View {
	let board: any Board
	var lightColor: Color = Color(.lightColour)
	var darkColor: Color = Color(.darkColour)
	var boardColor: Color = Color.backColour
	var lineColor: Color = Color(.systemGray2)
	var lineWidth: CGFloat = 1
	var useCutOut: Bool = false
	let doTap: (Position) -> ()
	var viewForItem: (Item, Position, Bool) -> ItemView

	var body: some View {
		let radius = 10.0
		let padding = radius
		HStack(spacing: 0) {
			ForEach(0..<board.columns, id: \.self) { column in
				VStack(spacing: 0) {
					ForEach(0..<board.rows, id: \.self) { row in
						let pos = Position(row: row, col: column)
						Rectangle()
							.fill(.clear)
							.stroke(.clear)
							.aspectRatio(1, contentMode: .fit)
							.overlay {
								let piece = board[pos] as! Item
								viewForItem(piece, pos, piece.isEmpty)
									.aspectRatio(1, contentMode: .fit)
							}
							.contentShape(Rectangle())
							.onTapGesture {
								print("Tap 2")
								doTap(pos)
							}
					}
				}
			}
		}
		.aspectRatio(CGFloat(board.columns)/CGFloat(board.rows), contentMode: .fit)
		.padding(padding)
		.background {
			if useCutOut {
				ShiftingGradientBackground()
			} else {
				SquaresView(board: board, lightColor: lightColor, darkColor: darkColor,
							boardColor: boardColor, lineColor: lineColor,
							lineWidth: lineWidth, useCutOut: useCutOut, doTap: doTap,
							padding: padding)
			}
		}
		.overlay {
			if useCutOut {
				SquaresView(board: board, lightColor: lightColor, darkColor: darkColor,
							boardColor: boardColor, lineColor: lineColor,
							lineWidth: lineWidth, useCutOut: useCutOut, doTap: doTap,
							padding: padding)
			}
			RoundedRectangle(cornerRadius: radius)
				.strokeBorder(useCutOut ? lightColor : Color.red, lineWidth: radius)
				.shadow(color: .gray, radius: !useCutOut ? radius : 0, x: 0, y: 0)
		}
		.clipShape(RoundedRectangle(cornerRadius: radius))
		.shadow(color: .gray, radius: useCutOut ? radius : 0, x: 0, y: 10)
	}
}

struct SquaresView: View {
	let board: any Board
	var lightColor: Color
	var darkColor: Color
	var boardColor: Color
	var lineColor: Color
	var lineWidth: CGFloat
	var useCutOut: Bool
	let doTap: (Position) -> ()
	let padding: CGFloat
	
	var body: some View {
		HStack(spacing: 0) {
			ForEach(0..<board.columns, id: \.self) { column in
				VStack(spacing: 0) {
					ForEach(0..<board.rows, id: \.self) { row in
						let isLight = (row + column).isMultiple(of: 2)
						Rectangle()
							.fill(isLight ? lightColor : darkColor)
							.stroke(lineColor, lineWidth: lineWidth)
							.reverseMask {
								Circle()
									.scaleEffect(0.9)
									.opacity(useCutOut ? 1 : 0)
							}
					}
				}
				.allowsHitTesting(useCutOut)
				.onTapGesture {
					print("Tap 3")
					if useCutOut {
						doTap(Position(row: 0, col: column))
					}
				}
			}
		}
		.aspectRatio(CGFloat(board.columns)/CGFloat(board.rows), contentMode: .fit)
		.padding(padding)
	}
}

struct ShiftingGradientBackground: View {
	@State private var animateGradient = true

	var body: some View {
		LinearGradient(
			colors: [.green.mix(with: .black, by: 0.3), .purple.mix(with: .black, by: 0.3),
					 .pink.mix(with: .black, by: 0.3), .orange.mix(with: .black, by: 0.3)],
			startPoint: animateGradient ? .topLeading : .bottomLeading,
			endPoint: animateGradient ? .bottomTrailing : .topTrailing
		)
		.ignoresSafeArea()
		.onAppear {
			withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: true)) {
				animateGradient.toggle()
			}
		}
	}
}

extension View {
	@ViewBuilder
	func reverseMask<Mask: View>(
		alignment: Alignment = .center,
		@ViewBuilder _ mask: () -> Mask
	) -> some View {
		self.mask {
			Rectangle()
				.overlay(alignment: alignment) {
					mask()
						.blendMode(.destinationOut)
				}
		}
	}
}
