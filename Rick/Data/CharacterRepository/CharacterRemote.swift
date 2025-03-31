//
//  CharacterRemote.swift
//  Rick
//
//  Created by Ludvig Hemma on 2025-03-31.
//

import Foundation

final class CharacterRemote: Sendable {

  private let rickClient: RickApiProtocol

  init() {
    self.rickClient = RickApi()
  }

  func fetchCharacters() async throws(CharacterRepositoryError) -> [Character] {
    do {
      return try await rickClient.fetchCharacters(page: 1).results
    } catch {
      throw .fetchError(error)
    }
  }

  func fetchImage(character: Character) async throws(CharacterRepositoryError) -> Data? {
    nil
  }
}
