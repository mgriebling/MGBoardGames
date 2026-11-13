//
//  ReversiBoardView.swift
//  MGReversi
//
//  Created by Mike Griebling on 2021-09-14.
//

import SwiftUI

struct BoardView<Item, ItemView: View>: View {
	var board: any Board
	var frameSize: CGFloat
	var boardColor: Color = Color.backColour
	var viewForItem: (Item, Position) -> ItemView
	
    public var body: some View {
		let lightBackground = Color(red: 181/255, green: 136/255, blue: 99/255)
		let darkBackground = Color(red:240/255, green: 217/255, blue: 181/255)
        Group {
			let radius = 12.0
			let cellSize = (frameSize - 2 * radius) / CGFloat(board.rows)
			let padding = radius
			let gridItem = GridItem(.flexible(), spacing: 0)
			let gridColumns = [GridItem](repeating: gridItem, count: board.columns)
			LazyVGrid(columns: gridColumns, spacing: 0) {
				ForEach(0..<board.rows, id: \.self) { row in
					ForEach(0..<board.columns, id: \.self) { column in
						let location = Position(row: row, col: column)
						self.viewForItem(board[location] as! Item, location)
							.font(.system(size: 9*cellSize/12))
							.aspectRatio(1, contentMode: .fit)
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
}

