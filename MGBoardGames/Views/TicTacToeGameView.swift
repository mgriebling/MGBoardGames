//
//  TicTacToeGameView.swift
//  MGBoardGames
//
//  Created by Michael Griebling on 06.11.2026.
//

import SwiftUI

struct TicTacToeGameView: View {
	var game: TicTacToeGame

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
					board(size: CGSize(width: boardWidth, height: boardWidth))
					VStack {
						HStack(alignment: .firstTextBaseline) {
							newGame.buttonStyle(.borderedProminent)
							Spacer()
							show.buttonStyle(.borderedProminent)
						}
						.font(.callout.bold())
						HStack {
							if isLandscape && game.activeColor == .whitePiece {
								Spacer()
							}
							Text("\(game.activePlayer.name)'s Move")
								.font(.title2).bold()
								.padding(.top, geometry.size.height/scale)
								.padding(.trailing, -15)
								.padding(.leading, -10)
							if isLandscape && game.activeColor == .blackPiece {
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
				game.player1 = settings.player1
				game.player2 = settings.player2
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
		let pieceColor = Color(.black)
		let shadow = Color.white
		let size = 2.5 * fontSize
		let active = player.colour == game.activePlayer.colour
		let textColor = active ? Color(.systemBackground) : Color(.systemGray)
		VStack(spacing: 0) {
			ZStack {
				Image(systemName: piece.description)
					.font(.system(size: size, weight: .heavy, design: .rounded))
					.foregroundStyle(pieceColor)
					.frame(width: size, height: size)
					.shadow(color: shadow, radius: 20, x: 5, y: 5)
					.padding(5)
			}
			Text(player.name)
				.padding(.bottom, 4)
				.foregroundColor(textColor).bold(active)
				.font(.system(size: 2*fontSize/3))
		}
		.background {
			Capsule(style: .circular)
				.fill(Color(.systemBlue).opacity(active ? 1 : 0))
				.padding(-10)
		}
	}
	
	@ViewBuilder
	func pieceView(piece: TicTacToePieces, position: Position) -> some View {
		ZStack {
			let size = 2.5 * fontSize
			let pieceColor = Color(.black)
			Rectangle().stroke(Color(.systemGray3), lineWidth: 3)
			Group {
				if piece == TicTacToePieces.empty {
					if showMoves && game.isValidMove(to: position, for: game.activePlayer) {
						let name = game.activeColor == .blackPiece ? "x.circle" : "o.circle"
						Image(systemName: name)
							.font(.system(size: size, weight: .heavy, design: .rounded))
							.foregroundStyle(pieceColor)
							.frame(width: size, height: size)
							.opacity(0.7)
					}
				} else {
					Image(systemName: piece.description)
						.font(.system(size: size, weight: .heavy, design: .rounded))
						.foregroundStyle(pieceColor)
						.frame(width: size, height: size)
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
						.contentShape(Rectangle())
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
					Group {
						if game.isDraw {
							Text("Game was a Draw!")
								.multilineTextAlignment(.center)
						} else {
							let winner = game.activePlayer == game.player1 ? game.player2 : game.player1
							Text("Game Over!\n\(winner.name)Wins!")
								.multilineTextAlignment(.center)
						}
					}
					.font(.system(size: 3*fontSize/2, weight: .heavy))
					.foregroundColor(.red)
					.shadow(color: .black, radius: 10)
					Spacer()
				}
			}
		}
	}
}

#Preview {
	let game = TicTacToeGame()
	TicTacToeGameView(game: game)
}
