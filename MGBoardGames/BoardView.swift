//
//  ReversiBoardView.swift
//  MGReversi
//
//  Created by Mike Griebling on 2021-09-14.
//

import SwiftUI

struct BoardView<E: GamePieceEnum, ItemView: View>: View {
	var board: GameBoard<E>
	var frameSize: CGFloat
	var viewForItem: (E.Enum, Position) -> ItemView
	
    public var body: some View {
        Group {
			let frameWidth = frameSize / CGFloat(board.rows*7)
			let cellSize = (frameSize - 2 * frameWidth) / CGFloat(board.rows)
			let padding = cellSize / 4
			let radius = cellSize / 5
			let gridItem = GridItem(.flexible(), spacing: 0)
			let gridColumns = [GridItem](repeating: gridItem, count: board.columns)
			LazyVGrid(columns: gridColumns, spacing: 0) {
				ForEach(0..<board.rows, id: \.self) { row in
					ForEach(0..<board.columns) { column in
						let location = Position(row: row, col: column)
						self.viewForItem(board[location], location)
							.font(.system(size: 10*cellSize/12))
							.aspectRatio(1, contentMode: .fit)
					}
				}
			}
			.aspectRatio(1, contentMode: .fit)
			.padding(padding)
			.background(Color(.systemIndigo))
			.clipShape(RoundedRectangle(cornerRadius: radius))
			.overlay(
				RoundedRectangle(cornerRadius: radius)
					.strokeBorder(Color.red, lineWidth: radius)
					.shadow(color: .black, radius: radius, x: 0, y: 0)
			)
        }
    }
}

