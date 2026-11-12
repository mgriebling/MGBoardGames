//
//  Settings.swift
//  MGReversi
//
//  Created by Mike Griebling on 2021-09-24.
//

import SwiftUI

enum GameModes: String, CaseIterable, Identifiable, Codable {
    case personVsComputer 	= "Person vs Computer"
    case personVsPerson   	= "Person vs Person"
    case computerVsComputer = "Computer vs Computer"
    case unknown
    
    var id: String { self.rawValue }
}

enum SkillLevel: String, CaseIterable, Identifiable, Codable {
    case novice
    case amateur
    case experienced
    case professional
    case champion
    
    var id: String { self.rawValue }
}

enum Kind: Int, CaseIterable, Identifiable, Codable {
    case person
    case computer
    
    var id: Int { self.rawValue }
}

enum PlayerColor: String, Codable, CaseIterable, Identifiable {
	case black = "Black Piece", white = "White Piece"
	
	var id: String { self.rawValue }
	
	var toggle: PlayerColor {
		if self == .black { return .white }
		return .black
	}
}

struct Player: Codable, Equatable {
    
    var name: String        // player's name
    var kind: Kind          // type of player
	var colour: PlayerColor	// player's game piece
    var skill: SkillLevel   // player's skill level
    
	var isStarting: Bool { colour == .black }
    
	init(name: String, kind: Kind = .person, colour: PlayerColor, skill: SkillLevel = .novice) {
        self.name = name
        self.kind = kind
        self.colour = colour
        self.skill = skill
    }
}

struct Background: Identifiable, Codable {
    
    let name: String
    var image: Image?
    var colour: Color?
    var id: String { name }
    
    init(name: String, image: Image? = nil, colour: Color? = nil) {
        self.name = name
        self.image = image
        self.colour = colour
    }
    
    var isImage: Bool { image != nil }
    
    func fillColour() -> Color {
        if let c = colour {
            return c
        }
        return Color.clear
    }
    
    func fillImage() -> Image {
        if let i = image {
            return i
        }
        return Image(systemName: "ellipsis")
    }
	
	enum CodingKeys: String, CodingKey {
		case name
		// ignore image and colour -- for now
	}
    
}

public struct Settings {
    
    var player1: Player         // description of first player
    var player2: Player         // description of second player
    var gameMode: GameModes     // game playing mode
    var backdrop: Background    // board backdrop
    var extensionsActive: Bool  // user bought extended options
    
    var backgrounds = [Background]()
    
	init(player1: Player = Player(name: "Mike", kind: .person, colour: .black),
		 player2: Player = Player(name: "Hal", kind: .computer, colour: .white),
		 gameMode: GameModes? = nil, extensionsActive: Bool = true) {
        self.player1 = player1
        self.player2 = player2
        if let mode = gameMode {
            self.gameMode = mode
        } else {
            if player1.kind == .person && player2.kind == .person {
                self.gameMode = .personVsPerson
            } else if player1.kind == .computer && player2.kind == .computer {
                self.gameMode = .computerVsComputer
            } else if (player1.kind == .person && player2.kind == .computer) ||
					  (player2.kind == .person && player1.kind == .computer) {
                self.gameMode = .personVsComputer
            } else {
                self.gameMode = .unknown
            }
        }
        self.backdrop = Background(name: "Default", colour: Color(.systemIndigo))
        self.extensionsActive = extensionsActive
        
        // build up the available backgrounds
        backgrounds.append(Background(name: "Denim", image: Image(.denim)))
        backgrounds.append(Background(name: "Texture 1", image: Image(.texture1)))
    }
	
	init(_ settings: Self) {
		self = settings
	}
    
}

public extension AppStorageKey where Value == Settings {
	static let settings = AppStorageKey("settings", defaultValue: Settings())
}

extension Settings: RawRepresentable {
	
	public init?(rawValue: String) {
		if let jsonData = rawValue.data(using: .utf8) {
			if let settings = try? JSONDecoder().decode(Settings.self, from: jsonData) {
				self.init(settings)
				return
			}
		}
		return nil
	}
	
	public var rawValue: String {
		do {
			let jsonData = try JSONEncoder().encode(self)
			let jsonString = String(data: jsonData, encoding: .utf8)
			return jsonString ?? "Unable to convert to string"
		} catch {
			return ""
		}
	}
}

extension Settings: Codable {
	enum CodingKeys: String, CodingKey {
		case player1, player2, gameMode, backdrop, extensionActive, backgrounds
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.player1 = try container.decode(Player.self, forKey: .player1)
		self.player2 = try container.decode(Player.self, forKey: .player2)
		self.gameMode = try container.decode(GameModes.self, forKey: .gameMode)
		self.backdrop = try container.decode(Background.self, forKey: .backdrop)
		self.extensionsActive = try container.decode(Bool.self, forKey: .extensionActive)
		self.backgrounds = try container.decode([Background].self, forKey: .backgrounds)
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.player1, forKey: .player1)
		try container.encode(self.player2, forKey: .player2)
		try container.encode(self.gameMode, forKey: .gameMode)
		try container.encode(self.backdrop, forKey: .backdrop)
		try container.encode(self.extensionsActive, forKey: .extensionActive)
		try container.encode(self.backgrounds, forKey: .backgrounds)
	}
}
