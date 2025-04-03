//
//  CharacterLocalStorage.swift
//  Rick
//
//  Created by Ludvig Hemma on 2025-03-31.
//

import Foundation

final class CharacterLocalStorage: Sendable {

  let imageCache = ImageCache.shared

  func storeCharacters(characters: [Character]) async {
    // TODO: Store in core data.
  }

  func fetchCharacters() async -> [Character]? {
    // TODO: Fetch from core data.
    nil
  }

  func storeImage(_ data: Data, character: Character) async {
    imageCache.storeImage(data, key: character.image)
  }

  func fetchImage(character: Character) async -> Data? {
    imageCache.fetchImage(key: character.image)
  }
}
