//
//  CharacterRemote.swift
//  Rick
//
//  Created by Ludvig Hemma on 2025-03-31.
//

import Foundation

/// Responsible for mapping types inside ``Domain/CoreModels`` to more primitive types suitable for a remote API.
final class CharacterRemote: Sendable {

  private let rickClient: RickApiProtocol

  init() {
    self.rickClient = RickApi()
  }

  func fetchCharacters(page: Int) async throws(CharacterRepositoryError) -> CharacterResponse {
    do {
      return try await rickClient.fetchCharacters(page: page)
    } catch {
      throw .fetchError(error)
    }
  }

  func fetchImage(character: Character) async throws(CharacterRepositoryError) -> Data {
    do {
      return try await rickClient.fetchImage(url: character.image)
    } catch {
      throw .fetchError(error)
    }
  }
}
