//
//  PreferencesView.swift
//  MGReversi
//
//  Created by Mike Griebling on 2021-09-19.
//

import SwiftUI

struct PreferencesView: View {
    
	@AppStorage(.settings) private var settings
	
    @Environment(\.presentationMode) var presentationMode
	
	var body: some View {
        NavigationView {
            VStack {
                Form {
					addModePicker
					switch settings.gameMode {
						case .personVsPerson:
							Section("Your Game Name") {
								TextField("First Name", text: $settings.player1.name)
								SelectColor(player: $settings.player1, player2: $settings.player2)
							}
							Section("Opponent's Name") {
								TextField("Opponent's First Name", text: $settings.player2.name)
								SelectColor(player: $settings.player2, player2: $settings.player1)
							}
						case .personVsComputer:
							Section("Your Game Name") {
								TextField("First Name", text: $settings.player1.name)
								SelectColor(player: $settings.player1, player2: $settings.player2)
							}
							Section("Computer Name") {
								TextField("Computer Name", text: $settings.player2.name)
								SelectColor(player: $settings.player2, player2: $settings.player1)
								addSkillLevel(name: "Computer Skill Level", level: $settings.player1.skill)
							}
						case .computerVsComputer:
							Section("Computer Name") {
								TextField("Computer Name", text: $settings.player1.name)
								SelectColor(player: $settings.player1, player2: $settings.player2)
								addSkillLevel(name: "Computer Skill Level", level: $settings.player1.skill)
							}
							Section("2nd Computer Name") {
								TextField("Computer 2 Name", text: $settings.player2.name)
								SelectColor(player: $settings.player2, player2: $settings.player1)
								addSkillLevel(name: "Computer 2 Skill Level", level: $settings.player2.skill)
							}
						default:
							Text("?")
					}

                    addBackdrop
                }
            }
            .navigationTitle("User Preferences")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Quit", systemImage: "xmark", action: {
                if presentationMode.wrappedValue.isPresented {
                    presentationMode.wrappedValue.dismiss()
                }
            }))
        }
        .onAppear {
            print("Settings name1 = \(settings.player1.name), name2 = \(settings.player2.name)")
        }
    }
    
    @State private var selection: String = ""
    
	var addBackdrop: some View {
		Section(header: Text("Board Backdrop")) {
			SelectionView(items: settings.backgrounds, selected: $selection)
		}
	}
	
	struct SelectColor: View {
		@Binding var player: Player
		@Binding var player2: Player
		var body: some View {
			Picker("Game Piece", selection: $player.colour) {
				ForEach(PlayerColor.allCases) { color in
					Text(color.rawValue).tag(color)
				}
			}
			.pickerStyle(.segmented)
			.onChange(of: player.colour) {
				withAnimation {
					player2.colour = player.colour.toggle
				}
			}
		}
	}
    
    struct SelectionView: View {
        var items: [Background]
        @Binding var selected: String

        var body: some View {
            List(items) { item in
                SelectionCell(item: item, selected: $selected)
            }
        }
    }

    struct SelectionCell: View {
        let item: Background
        @Binding var selected: String
        
        var body: some View {
            ZStack {
                Group {
                    if item.isImage {
                        item.fillImage().resizable()
                    } else {
                        item.fillColour()
                    }
                }
                .frame(height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.1))
                    .onTapGesture {
                        self.selected = self.item.name
                        print("Selected = \(selected)")
                    }
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(Color.accentColor, lineWidth: item.name == selected ? 4 : 0)
                    .overlay(Text(item.name))
            }
        }
    }
    
    var addModePicker: some View {
        Section(header: Text("Game Play Style")) {
			Picker("Game Setting", selection: $settings.gameMode.animation()) {
				ForEach(GameModes.allCases.dropLast()) { mode in
					Text("\(mode.rawValue)").tag(mode)
				}
            }
			.pickerStyle(.wheel)
            .frame(height: 100)
            .onChange(of: settings.gameMode) {
                withAnimation {
					switch settings.gameMode {
						case .computerVsComputer:
							settings.player1.kind = .computer
							settings.player2.kind = .computer
						case .personVsComputer:
							settings.player1.kind = .person
							settings.player2.kind = .computer
						default:
							settings.player1.kind = .person
							settings.player2.kind = .person
                    }
                }
            }
        }
    }

    func addSkillLevel(name: String, level: Binding<SkillLevel>) -> some View {
        Section(header: Text(name)) {
            Picker("Skill Level", selection: level) {
                ForEach(SkillLevel.allCases) { mode in
                    Text(mode.rawValue.capitalized).tag(mode)
                }
            }
			.pickerStyle(WheelPickerStyle())
            .frame(height: 100)
        }
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
