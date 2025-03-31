//
//  CharacterLocalStorage.swift
//  Rick
//
//  Created by Ludvig Hemma on 2025-03-31.
//

import Foundation

final class CharacterLocalStorage: Sendable {

  func storeCharacters(characters: [Character]) async {

  }

  func fetchCharacters() async -> [Character]? {
    nil
  }

  func storeImage(_ image: Data, character: Character) {

  }

  func fetchImage(character: Character) async -> Data? {
    nil
  }
}
