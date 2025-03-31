//
//  CharactersViewModel.swift
//  Rick
//
//  Created by Ludvig Hemma on 2025-03-29.
//

import UIKit

@MainActor
class CharactersViewModel {

  private let characterService: CharacterServiceProtocol
  let rick: Character

  init() {
    self.characterService = CharacterService()
    rick = Self.loadSampleData()
    print(rick)

    Task {
      let data = try? await characterService.fetchCharacters()
      print(data)
    }
  }

  private static func loadSampleData() -> Character {
    let decoder = JSONDecoder()
//    decoder.keyDecodingStrategy = .convertFromSnakeCase
    let characterData = try! Data(contentsOf: Bundle.main.url(forResource: "samplecharacter", withExtension: "json")!)
    let character = try! decoder.decode(Character.self, from: characterData)
    return character
  }

  

}

