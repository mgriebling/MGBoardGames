//
//  ReversiGameView.swift
//  MGBoardGames
//
//  Created by Michael Griebling on 06.11.2026.
//

import SwiftUI

struct ReversiGameView: View {
	var game: ReversiGame

	@State private var showMoves = false
	@State private var showPreferences = false
	@State private var boardWidth = CGFloat(300)
	@State private var fontSize = CGFloat(50)
	@State private var isLandscape = false
	
	@AppStorage(.settings) private var settings
	
	var body: some View {
		GeometryReader { geometry in
			let newGame = Button("New Game") {
				withAnimation { game.newGame() }
			}
			let show = Button(showMoves ? "Hide Moves" : "Show Moves") {
				withAnimation { showMoves.toggle() }
			}
			VStack {
				ZStack {
					board(size: CGSize(width: boardWidth, height: boardWidth))
					VStack{
						HStack(alignment: .firstTextBaseline) {
							newGame.padding()
							Spacer()
							show.padding()
						}
						.font(.callout.bold())
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
				game.player1 = settings.player1
				game.player2 = settings.player2
			}
			.onChange(of: geometry.size) {
				determineWidth(size: geometry.size)
			}
		}
		.gesture(swipeGesture())
		.onDisappear {
			print("Saving board...")
			game.saveGame()
		}
	}
	
	func determineWidth(size: CGSize) {
		boardWidth = min(size.width, size.height)
		print("Width = \(boardWidth)")
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
		let score = game.board.score(game.color(for: player))
		let shadow = Color.black
		let color = player.colour == .black ? Color.white : .black
		let active = player.colour == game.activePlayer.colour
		let textColor = active ? Color(.systemBackground) : Color(.systemGray)
		VStack(spacing: 0) {
			ZStack {
				Text(piece.description).font(.system(size: fontSize * 2))
					.shadow(color: shadow, radius: 20, x: 5, y: 5)
					.padding(5)
				Text("\(score)")
					.foregroundColor(color).bold()
					.font(.system(size: fontSize))
			}
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
	
	@ViewBuilder
	func pieceView(piece: ReversiPieces, position: BoardCoordinate) -> some View {
		ZStack {
			Rectangle().stroke(Color(.systemGray3))
			Group {
				if piece == ReversiPieces.empty {
					if showMoves && game.isValidMove(to: position, for: game.activePlayer) {
						Image(systemName: "checkmark.circle")
							.foregroundColor(game.activeColor == .whitePiece ? Color.white : .black)
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
	
	func board (size: CGSize) -> some View {
		ZStack {
			VStack {
				Spacer(minLength: 0)
				let boardWidth = min(size.width, size.height)
				BoardView(board: game.board, frameSize: boardWidth) { piece, position in
					pieceView(piece: piece, position: position)
						.onTapGesture {
							game.handleTap(at: position)
						}
				}
				.blur(radius: game.gameIsOver ? 3 : 0)
				Spacer(minLength: 0)
			}
			if game.gameIsOver {
				VStack {
					Spacer()
					let winner = game.player1Score > game.player2Score ? game.player1 : game.player2
					Text("Game Over!\n\(winner.name) Wins!").font(.system(size: 3*fontSize/2, weight: .heavy))
						.foregroundColor(.red)
						.shadow(color: .black, radius: 10)
					Spacer()
				}
			}
		}
	}
}

#Preview {
	let settings = Settings()
	let game = ReversiGame(player1: settings.player1, player2: settings.player2)
	ReversiGameView(game: game)
}
