//
//  View+Cutout.swift
//  MGBoardGames
//
//  Created by Michael Griebling on 25.11.2026.
//

import SwiftUI

extension View {

	func reverseMask<Mask: View>(alignment: Alignment = .center,
								 @ViewBuilder _ mask: () -> Mask) -> some View {
		self.mask {
			Rectangle()
				.overlay(alignment: alignment) {
					mask().blendMode(.destinationOut)
				}
		}
	}
}
