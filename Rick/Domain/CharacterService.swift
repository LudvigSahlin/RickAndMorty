//
//  CharacterService.swift
//  Rick
//
//  Created by Ludvig Hemma on 2025-03-30.
//

import UIKit

protocol CharacterServiceProtocol: Sendable {
  func fetchCharacters() async throws(CharacterServiceError) -> [Character]
  func fetchLocalImage(character: Character) async -> UIImage?
  func fetchImage(character: Character) async throws(CharacterServiceError) -> UIImage?
}

enum CharacterServiceError: Error {
  case fetchError(_ error: Error)
}

final class CharacterService: CharacterServiceProtocol {

  private let repository: CharacterRepositoryProtocol

  init() {
    self.repository = CharacterRepository()
  }

  func fetchCharacters() async throws(CharacterServiceError) -> [Character] {
    do {
      return try await repository.fetchCharacters()
    } catch {
      throw .fetchError(error)
    }
  }

  func fetchLocalImage(character: Character) async -> UIImage? {
    nil
  }

  func fetchImage(character: Character) async throws(CharacterServiceError) -> UIImage? {
    nil
  }
}
