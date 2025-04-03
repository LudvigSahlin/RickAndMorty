//
//  CharacterRepository.swift
//  Rick
//
//  Created by Ludvig Hemma on 2025-03-31.
//

import Foundation

protocol CharacterRepositoryProtocol: Sendable {
  func fetchCharacters(page: Int) async throws(CharacterRepositoryError) -> CharacterResponse
  func fetchLocalImage(character: Character) async -> Data?
  func fetchImage(character: Character) async throws(CharacterRepositoryError) -> Data
}

enum CharacterRepositoryError: Error {
  case fetchError(_ error: Error)
}

/// Responsible for storing remotelly fetched data to local storage.
final class CharacterRepository: CharacterRepositoryProtocol {

  private let remote: CharacterRemote
  private let localStorage: CharacterLocalStorage

  init() {
    self.remote = CharacterRemote()
    self.localStorage = CharacterLocalStorage()
  }

  func fetchCharacters(page: Int) async throws(CharacterRepositoryError) -> CharacterResponse {
    try await remote.fetchCharacters(page: page)
  }
  
  func fetchLocalImage(character: Character) async -> Data? {
    await localStorage.fetchImage(character: character)
  }
  
  func fetchImage(character: Character) async throws(CharacterRepositoryError) -> Data {
    do {
      let imageData = try await remote.fetchImage(character: character)
      await localStorage.storeImage(imageData, character: character)
      return imageData
    } catch {
      throw .fetchError(error)
    }
  }
}
