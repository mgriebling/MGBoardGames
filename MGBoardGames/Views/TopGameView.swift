//
//  ReversiGameView.swift
//  MGBoardGames
//
//  Created by Michael Griebling on 06.11.2026.
//

import SwiftUI

struct TopGameView<BView: View>: View {
	var game: any Game
	var gameView: (Bool) -> BView

	@State private var showMoves = false
	@State private var showPreferences = false
	@State private var boardWidth = CGFloat(300)
	@State private var fontSize = CGFloat(50)
	@State private var isLandscape = false
	
	@AppStorage(.settings) private var settings
	
	var body: some View {
		let scale: CGFloat = isLandscape ? 4 : 15
		GeometryReader { geometry in
			let newGame = Button("New Game") {
				withAnimation { game.newGame() }
			}
			let show = Button(showMoves ? "Hide Moves" : "Show Moves") {
				withAnimation { showMoves.toggle() }
			}
			VStack {
				ZStack {
					board(size: geometry.size)
					VStack {
						HStack(alignment: .firstTextBaseline) {
							newGame.buttonStyle(.borderedProminent)
							Spacer()
							show.buttonStyle(.borderedProminent)
						}
						.font(.callout.bold())
						HStack {
							if isLandscape && game.activePlayer.colour == .white {
								Spacer()
							}
							Text("\(game.activePlayer.name)'s Move")
								.font(.title2).bold()
								.padding(.top, geometry.size.height/scale)
								.padding(.trailing, -15)
								.padding(.leading, -10)
							if isLandscape && game.activePlayer.colour == .black {
								Spacer()
							}
						}
						Spacer()
						HStack {
							scorePiece(player: settings.player1, fontSize: fontSize)
							Spacer()
							scorePiece(player: settings.player2, fontSize: fontSize)
						}
						.padding(3*fontSize/5)
					}
				}
			}
			.background(Color.gray.opacity(0.01))  // swipe gesture isn't recognized on default background
			.sheet(isPresented: $showPreferences) {
				PreferencesView()
			}
			.onAppear {
				determineWidth(size: geometry.size)
				game.set(player1: settings.player1, player2: settings.player2)
			}
			.onChange(of: geometry.size) {
				determineWidth(size: geometry.size)
			}
		}
		.gesture(swipeGesture())
		.onDisappear {
			game.saveGame()
		}
	}
	
	func determineWidth(size: CGSize) {
		boardWidth = min(size.width, size.height)
		isLandscape = size.width > size.height
		print("Board changed to: \(boardWidth), size = \(size)")
		if UIDevice.current.model.hasPrefix("iPad Pro") {
			fontSize =  boardWidth / 20
		} else if UIDevice.current.model.hasPrefix("iPad") {
			fontSize =  boardWidth / 22
		} else {
			fontSize =  boardWidth / 12
		}
	}
	
	func swipeGesture() -> some Gesture {
		DragGesture().onEnded { finalValue in
			if finalValue.translation.height < -100 {
				print("Swipe up")
				showPreferences = true
			}
		}
	}
	
	@ViewBuilder
	func scorePiece (player: Player, fontSize: CGFloat) -> some View {
		let piece = game.color(for: player)
		let score = game.score(for: player)
		let shadow = Color.black
		let color = player.colour == .black ? Color.white : .black
		let active = player.colour == game.activePlayer.colour
		let textColor = active ? Color(.systemBackground) : Color(.systemGray)
		VStack(spacing: 0) {
			Group {
				if game.usesImages {
					Image(systemName: piece.description)
						.font(.system(size: fontSize * 2, weight: .heavy, design: .rounded))
				} else {
					ZStack {
						Text(piece.description)
							.font(.system(size: fontSize * 2))
						Text("\(score)")
							.foregroundColor(color).bold()
							.font(.system(size: fontSize))
					}
				}
			}
			.shadow(color: shadow, radius: 20, x: 5, y: 5)
			.padding(5)
			Text(player.name)
				.padding(.bottom, 4)
				.foregroundColor(textColor).bold(active)
				.font(.system(size: 2*fontSize/3))
		}
		.background {
			Capsule(style: .circular)
				.fill(.blue.opacity(active ? 1 : 0))
				.padding(-10)
		}
	}
	
	func board (size: CGSize) -> some View {
		ZStack {
			gameView(showMoves)
			if game.gameIsOver {
				VStack {
					Spacer()
					let winner = game.player1Score > game.player2Score ? game.player1 : game.player2
					Text("Game Over!\n\(winner.name) Wins!")
						.font(.system(size: 3*fontSize/2, weight: .heavy))
						.foregroundColor(.red)
						.shadow(color: .black, radius: 10)
					Spacer()
				}
			}
		}
	}
}

#Preview("Reversi") {
	let game = ReversiGame()
	TopGameView(game: game) { showMoves in
		ReversiGameView(game: game, showMoves: showMoves)
	}
}

#Preview("Tic-Tac-Toe") {
	let game = TicTacToeGame()
	TopGameView(game: game) { showMoves in
		TicTacToeGameView(game: game, showMoves: showMoves)
	}
}
