//
//  MGBoardGamesApp.swift
//  MGBoardGames
//
//  Created by Michael Griebling on 06.11.2026.
//

import SwiftUI

@main
struct MGBoardGamesApp: App {
    var body: some Scene {
        WindowGroup {
			GameSelectionView()
        }
    }
}

struct GameSelectionView: View {

	var body: some View {
		NavigationStack {
			ScrollView {
				LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
					ForEach(GameList.allCases) { game in
						NavigationLink(value: game) {
							VStack(spacing: 0) {
								Text(game.name)
									.font(.headline)
								Image(game.image)
									.resizable()
									.aspectRatio(1, contentMode: .fit)
							}
						}
						.buttonStyle(.plain)
					}
				}
				.padding(.horizontal)
			}
			.navigationTitle("Select A Game")
			.navigationDestination(for: GameList.self) { selected in
				ItemDetailView(item: selected)
			}
		}
	}
}

struct ItemDetailView: View {
	let item: GameList
	
	@State var reversi = ReversiGame(player1: Player(name: "Dummy1", colour: .black), player2: Player(name: "Dummy2", colour: .white))
	
	var body: some View {
		Group {
			switch item {
				case .reversi: ReversiGameView(game: reversi)
				// case .tictactoe: TicTacToeGameView(game: tictactoe)
				default:
					VStack(spacing: 20) {
						RoundedRectangle(cornerRadius: 20)
							.fill(.red.gradient)
							.frame(height: 250)
							.padding()
						Text(item.name)
							.font(.largeTitle)
							.bold()
						Spacer()
					}
			}
		}
		//.navigationTitle(item.name)
		.toolbar {
			ToolbarItem(placement: .principal) {
				Text(item.name)
					.kerning(0)
					.foregroundColor(.gray)
					.font(.title2.lowercaseSmallCaps().weight(.black))
			}
		}
		.navigationBarTitleDisplayMode(.inline)
	}
}

#Preview {
	GameSelectionView()
}
