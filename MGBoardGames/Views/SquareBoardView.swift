//
//  ReversiGameView.swift
//  MGBoardGames
//
//  Created by Michael Griebling on 06.11.2026.
//

import SwiftUI

struct SquareBoardView<Item: GamePieceEnum, ItemView: View>: View {
	let board: any Board
	var selection: Position? = nil
	var lightColor: Color = Color(.lightColour)
	var darkColor: Color = Color(.darkColour)
	var boardColor: Color = Color.backColour
	var lineColor: Color = Color(.systemGray2)
	var lineWidth: CGFloat = 1
	var useCutOut: Bool = false
	let doTap: (Position) -> ()
	var viewForItem: (Item, Position, Bool) -> ItemView

	var body: some View {
		let radius = 10.0 + 4
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
							.onTapGesture { doTap(pos) }
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
				squaresView(padding: padding)
			}
		}
		.overlay {
			if useCutOut {
				squaresView(padding: padding)
			}
			RoundedRectangle(cornerRadius: radius)
				.strokeBorder(useCutOut ? lightColor : darkColor, lineWidth: radius)
			
				// Add square designators to the left and bottom of the board
				.overlay {
					// Number the board edges
					ZStack {
						// Creates the vertical row numbers
						HStack {
							VStack {
								Spacer()
								ForEach((1...board.rows).reversed(), id: \.self) { row in
									Text(row, format: .number)
										.foregroundStyle(lightColor)
										.padding(.leading, 1)
									Spacer()
								}
							}
							Spacer()
						}
						
						// Creates the horizontal column letters
						VStack {
							let aCode = Int(Character("A").asciiValue!)
							Spacer()
							HStack(spacing: radius/2) {
								Spacer()
								ForEach(0..<board.columns, id: \.self) { col in
									Text(String(UnicodeScalar(aCode+col)!))
										.foregroundStyle(lightColor)
										.padding(.bottom, -3)
									Spacer()
								}
							}
						}
					}
				}
		}
		.clipShape(RoundedRectangle(cornerRadius: radius))
		.shadow(color: .black, radius: radius, x: 0, y: useCutOut ? 10 : 0)
	}
	
	func squaresView(padding: CGFloat) -> some View {
		HStack(spacing: 0) {
			ForEach(0..<board.columns, id: \.self) { column in
				VStack(spacing: 0) {
					ForEach(0..<board.rows, id: \.self) { row in
						let isLight = (row + column).isMultiple(of: 2)
						let highlight = isLight ? darkColor : lightColor
						let selected = Position(row: row, col: column) == selection
						Rectangle()
							.fill(isLight ? lightColor : darkColor)
							.stroke(lineColor, lineWidth: lineWidth)
							.overlay {
								// highlight the square when piece is active
								Rectangle()
									.fill(
										RadialGradient(
											colors: [highlight, .clear],
											center: .center,
											startRadius: 0,
											endRadius: selected ? 50 : 0
										)
									)
							}
							.reverseMask {
								Circle()
									.scaleEffect(0.9)
									.opacity(useCutOut ? 1 : 0)
							}
					}
				}
				.allowsHitTesting(useCutOut)
				.onTapGesture {
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
