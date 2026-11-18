//
//  ReversiGameView.swift
//  MGBoardGames
//
//  Created by Michael Griebling on 06.11.2026.
//

import SwiftUI

struct SquareBoardView<Item, ItemView: View>: View {
	let board: any Board
	var lightColor: Color = Color(.lightColour)
	var darkColor: Color = Color(.darkColour)
	var boardColor: Color = Color.backColour
	var lineColor: Color = Color(.systemGray2)
	var lineWidth: CGFloat = 1
	let doTap: (Position) -> ()
	var viewForItem: (Item, Position) -> ItemView

	var body: some View {
		let radius = 10.0
		let padding = radius
		VStack(spacing: 0) {
			ForEach(0..<board.columns, id: \.self) { column in
				HStack(spacing: 0) {
					ForEach(0..<board.rows, id: \.self) { row in
						let isLight = (row + column).isMultiple(of: 2)
						Rectangle()
							.fill(isLight ? lightColor : darkColor)
							.stroke(lineColor, lineWidth: lineWidth)
							.overlay {
								let position = Position(row: row, col: column)
								let piece = board[position]
								viewForItem(piece as! Item, position)
							}
							.contentShape(Rectangle())
							.onTapGesture {
								doTap(Position(row: row, col: column))
							}
					}
				}
			}
		}
		.aspectRatio(1, contentMode: .fit)
		.padding(padding)
		.background(boardColor)
		.clipShape(RoundedRectangle(cornerRadius: radius))
		.overlay(
			RoundedRectangle(cornerRadius: radius)
				.strokeBorder(Color.red, lineWidth: radius)
				.shadow(color: .black, radius: radius, x: 0, y: 0)
		)
	}
}
