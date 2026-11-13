//
//  ReversiGameView.swift
//  MGBoardGames
//
//  Created by Michael Griebling on 06.11.2026.
//

import SwiftUI

struct GomokuGameView: View {
	var game: GomokuGame

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
			.onChange(of: settings.player1) {
				game.player1 = settings.player1
			}
			.onChange(of: settings.player2) {
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
		let score = game.board.score(game.color(for: player))
		let shadow = Color.black
		let color = player.colour == .black ? Color.white : .black
		let active = player.colour == game.activePlayer.colour
		let textColor = active ? Color(.systemBackground) : Color(.systemGray)
		VStack(spacing: 0) {
			Text(piece.description).font(.system(size: fontSize * 2))
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
	
	@ViewBuilder
	func pieceView(piece: GomokuPieces, position: Position) -> some View {
		ZStack {
			Rectangle().stroke(.clear)
			Group {
				if piece == GomokuPieces.empty {
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
	
	@ViewBuilder
	func GomokuView(width: CGFloat) -> some View {
		let goSize = game.columns == 19
		let increment = width / CGFloat(game.columns+1)
		let thickness = 1.0
		let dotSize = 6.0
		let dotSpacing = increment * (goSize ? 6 : 4)
		let dotStart = increment * 4
		let lineLength = width-CGFloat(2*increment)
		let halfField = width/2
		let lineColor = Color.black
		let radius = 10.0
		
		Rectangle().fill(Color.backColour)
			.clipShape(RoundedRectangle(cornerRadius: radius))
		
		// draw horizontal lines
		ForEach(1...game.columns, id:\.self) { col in
			Rectangle()
				.foregroundStyle(lineColor)
				.frame(width: lineLength, height: thickness)
				.position(x: halfField, y: CGFloat(col)*increment)
		}
		
		// draw vertical lines
		ForEach(1...game.rows, id:\.self) { row in
			Rectangle()
				.foregroundStyle(lineColor)
				.frame(width: thickness, height: lineLength)
				.position(x: CGFloat(row)*increment, y: halfField)
		}
		
		// draw dots at intersection points
		ForEach(0..<3, id: \.self) { vdot in
			ForEach(0..<3, id: \.self) { dot in
				if goSize || vdot == dot || vdot == (dot-2) || (vdot-2) == dot {
					Circle()
						.foregroundStyle(lineColor)
						.frame(width: dotSize, height: dotSize)
						.position(x: dotStart + CGFloat(dot)*dotSpacing,
								  y: dotStart + CGFloat(vdot)*dotSpacing)
				}
			}
		}
	}
	
	func board (size: CGSize) -> some View {
		ZStack {
			VStack {
				Spacer(minLength: 0)
				let boardWidth = min(size.width, size.height)
				BoardView(board: game.board, frameSize: boardWidth, boardColor: .clear) { piece, position in
					pieceView(piece: piece, position: position)
						.contentShape(Rectangle()) // needed so tap works
						.onTapGesture {
							game.handleTap(at: position)
						}
				}
				.background(GomokuView(width: boardWidth))
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
	let game = GomokuGame()
	GomokuGameView(game: game)
}
