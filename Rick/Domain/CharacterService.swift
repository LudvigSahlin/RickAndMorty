//
//  CharacterService.swift
//  Rick
//
//  Created by Ludvig Hemma on 2025-03-30.
//

import UIKit

protocol CharacterServiceProtocol: Sendable {
  func fetchCharacters(page: Int) async throws(CharacterServiceError) -> (
    hasMoreData: Bool,
    data: [Character]
  )

  func fetchLocalImage(character: Character) async -> UIImage?
  func fetchImage(character: Character) async throws(CharacterServiceError) -> UIImage?

//  func allCharactersFetched() async -> Bool
//  func characters() async -> [Character]
}

enum CharacterServiceError: Error {
  case fetchError(_ error: Error)
}

final class CharacterService: CharacterServiceProtocol {

  private let repository: CharacterRepositoryProtocol
//  private(set) var allCharactersFetched = false
//  private(set) var characters: [Character] = []

  init() {
    self.repository = CharacterRepository()
  }

  func fetchCharacters(page: Int) async throws(CharacterServiceError) -> (
    hasMoreData: Bool,
    data: [Character]
  ) {
    do {
      let response = try await repository.fetchCharacters(page: page)
      let hasMoreData = response.info.next != nil
      return (hasMoreData, response.results)
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
