//
//  CharacterRepository.swift
//  Rick
//
//  Created by Ludvig Hemma on 2025-03-31.
//

import Foundation

protocol CharacterRepositoryProtocol: Sendable {
  func fetchCharacters() async throws(CharacterRepositoryError) -> [Character]
  func fetchLocalImage(character: Character) async -> Data?
  func fetchImage(character: Character) async throws(CharacterRepositoryError) -> Data?
}

enum CharacterRepositoryError: Error {
  case fetchError(_ error: Error)
//  case internalError
}

final class CharacterRepository: CharacterRepositoryProtocol {

  private let remote: CharacterRemote
  private let localStorage: CharacterLocalStorage

  init() {
    self.remote = CharacterRemote()
    self.localStorage = CharacterLocalStorage()
  }

  func fetchCharacters() async throws(CharacterRepositoryError) -> [Character] {
    try await remote.fetchCharacters()
  }
  
  func fetchLocalImage(character: Character) async -> Data? {
    nil
  }
  
  func fetchImage(character: Character) async throws(CharacterRepositoryError) -> Data? {
    nil
  }
  

}
