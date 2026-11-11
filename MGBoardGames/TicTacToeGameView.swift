//
//  TicTacToeGameView.swift
//  MGBoardGames
//
//  Created by Michael Griebling on 06.11.2026.
//

import SwiftUI

//struct TicTacToeGameView: View {
//	var game: TicTacToeGame
//	
//	//@State private var illegalMove : TicTacToeGameBoard.Position?
//	@State private var gameIsOver = false
//	@State private var showMoves = false
//	@State private var showPreferences = false
//	@State private var boardWidth = CGFloat(300)
//	@State private var fontSize = CGFloat(50)
//	@State private var isLandscape = false
//	
//	@AppStorage(.settings) private var settings
//	
//	func determineWidth(size: CGSize) {
//		boardWidth = min(size.width, size.height)
//		if UIDevice.current.model.hasPrefix("iPad Pro") {
//			fontSize =  boardWidth / 20
//		} else if UIDevice.current.model.hasPrefix("iPad") {
//			fontSize =  boardWidth / 22
//		} else {
//			fontSize =  boardWidth / 12
//		}
//	}
//	
//	var body: some View {
//		GeometryReader { geometry in
//			let newGame = Button("New Game") {
//				withAnimation { game.newGame() }
//			}
//			let show = Button(showMoves ? "Hide Moves" : "Show Moves") {
//				withAnimation { showMoves.toggle() }
//			}
//			VStack {
//				ZStack {
//					board(size: CGSize(width: boardWidth, height: boardWidth))
//					VStack{
//						if !isLandscape {
//							Text(TicTacToeGame.name)
//								.kerning(0)
//								.foregroundColor(.gray)
//								.font(.title2.lowercaseSmallCaps().weight(.black))
//						} else {
//							HStack {
//								Spacer()
//								Text(ReversiGame.name)
//									.kerning(0)
//									.foregroundColor(.gray)
//									.font(.title2.lowercaseSmallCaps().weight(.black))
//							}
//						}
//						HStack(alignment: .firstTextBaseline) {
//							newGame.padding()
//							Spacer()
//							show.padding()
//						}
//						.font(.callout.bold())
//						Spacer()
//						HStack {
//							scorePiece(player: settings.player1, fontSize: fontSize)
//							Spacer()
//							scorePiece(player: settings.player2, fontSize: fontSize)
//						}
//						.padding(3*fontSize/5)
//					}
//				}
//			}
//			//.padding(.horizontal)
//			.background(Color.gray.opacity(0.01))  // swipe gesture isn't recognized on default background
//			.sheet(isPresented: $showPreferences) {
//				PreferencesView()
//			}
//			.onAppear {
//				determineWidth(size: geometry.size)
//			}
//			.onChange(of: UIDevice.current.orientation) {
//				determineWidth(size: geometry.size)
//			}
//		}
//		.gesture(swipeGesture())
//		.onDisappear {
//			print("Saving board...")
//			game.saveGame()
//		}
//	}
//	
//	func swipeGesture() -> some Gesture {
//		DragGesture().onEnded { finalValue in
//			if finalValue.translation.height < -100 {
//				print("Swipe up")
//				showPreferences = true
//			}
//		}
//	}
//	
//	@ViewBuilder
//	func scorePiece (player: Player, fontSize: CGFloat) -> some View {
//		let piece = player.colour
//		let score = piece == .whitePiece ? game.whiteScore : game.blackScore
//		let color = piece == .whitePiece ? Color.black : .white
//		let shadow = piece == game.player ? Color.white : .clear
//		VStack(spacing: 0) {
//			ZStack {
//				Text(piece.description).font(.system(size: fontSize * 1.5))
//					.scaleEffect(piece == game.player ? 1.2 : 1.0)
//					.shadow(color: shadow, radius: 20, x: 0, y: 0)
//				Text("\(score)")
//					.foregroundColor(color).bold()
//					.font(.system(size: fontSize))
//			}
//			Text(player.name)
//				.padding(4)
//				.foregroundColor(.gray)
//				.font(.system(size: 2*fontSize/3))
//		}
//	}
//	
//	func handleTap(_ row: Int, column: Int) {
//		if game.setPiece(row, column: column) {
//			illegalMove = nil
//		} else {
//			illegalMove = (row, column)
//			Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
//				illegalMove = nil       // clear illegal move square after some time
//			}
//		}
//		if game.isGameOver {
//			gameIsOver = true
//			Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
//				gameIsOver = false  // clear message after some time
//			}
//		}
//		print("Saving board...")
//		game.saveGame()
//	}
//	
//	func board (size: CGSize) -> some View {
//		ZStack {
//			VStack {
//				Spacer(minLength: 0)
//				let boardWidth = min(size.width, size.height)
//				BoardView(game.board, width: boardWidth, rows: game.rows, columns: game.columns) { piece, row, column in
//					ZStack {
//						Rectangle().stroke(Color(.systemGray3))
//						Group {
//							if let illegal = illegalMove, illegal == (row, column) {
//								Text("🚫")
//							} else if piece == .empty {
//								if showMoves && game.isValidMove(row, column: column) {
//									Image(systemName: "checkmark.circle")
//										.foregroundColor(game.player == .whitePiece ? Color.white : .black)
//										.opacity(0.5)
//								} else {
//									Text(piece.description)
//								}
//							} else {
//								withAnimation {
//									Text(piece.description)
//								}
//							}
//						}
//						.shadow(color: .black.opacity(0.5), radius: 2, x:2, y:2)
//					}
//					.onTapGesture {
//						withAnimation {
//							handleTap(row, column: column)
//						}
//					}
//				}.blur(radius: gameIsOver ? 3 : 0)
//				Spacer(minLength: 0)
//			}
//			if gameIsOver {
//				VStack {
//					Spacer()
//					let winner = game.blackScore > game.whiteScore ? "Black" : "White"
//					Text("Game Over!\n\(winner) Wins!").font(.system(size: 3*fontSize/2, weight: .heavy))
//						.foregroundColor(.red)
//						.shadow(color: .black, radius: 10)
//					Spacer()
//				}
//			}
//		}
//	}
//}
//
//#Preview {
//	let game = TicTacToeGame()
//	TicTacToeGameView(game: game)
//}
