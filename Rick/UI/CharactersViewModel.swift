//
//  CharactersViewModel.swift
//  Rick
//
//  Created by Ludvig Hemma on 2025-03-29.
//

import UIKit
import Combine

@MainActor
class CharactersViewModel {

  private let characterService: CharacterServiceProtocol
  private var currentPage: Int = 0
  private var hasLoadedAllCharacters = false

  private lazy var sampleCharacter = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    let characterData = try! Data(contentsOf: Bundle.main.url(forResource: "samplecharacter", withExtension: "json")!)
    let character = try! decoder.decode(Character.self, from: characterData)
    return character
  }()

  private let uiStatePrivatePublisher = CurrentValueSubject<CharactersViewController.UiState, Never>(.idle)
  var uiStatePublisher: AnyPublisher<CharactersViewController.UiState, Never> {
    uiStatePrivatePublisher.eraseToAnyPublisher()
  }

  private let listStatePrivatePublisher = CurrentValueSubject<CharactersViewController.ListState, Never>(.idle)
  var listStatePublisher: AnyPublisher<CharactersViewController.ListState, Never> {
    listStatePrivatePublisher.eraseToAnyPublisher()
  }

  private(set) var characters: [Character] = []

  init() {
    self.characterService = CharacterService()

    Task {
      await refreshData()
    }
  }

  /// > Side effect:
  /// > Updates ``currentPage``, ``characters`` and ``hasLoadedAllCharacters`` on success.
  private func fetchNextPage(fetchFromBeginning: Bool = false) async throws(CharacterServiceError) {
    if hasLoadedAllCharacters {
      return
    }
    let nextPage = fetchFromBeginning ? 1 : currentPage + 1
    let (hasMoreData, characters) = try await characterService.fetchCharacters(page: nextPage)
    currentPage = nextPage
    hasLoadedAllCharacters = !hasMoreData
    if fetchFromBeginning {
      self.characters = characters
    } else {
      self.characters.append(contentsOf: characters)
    }
  }

  func onAction(_ action: CharactersViewController.Action) {
    Task {
      switch action {
      case .refreshData:
        await refreshData()
      case .scrolledToBottom:
        await fetchMoreData()
      case .tappedOnCharacter(let id):
        presentDetailView(id: id)
      }
    }
  }

  /// > Side effect: Updates ``uiStatePublisher``.
  private func refreshData() async {
    uiStatePrivatePublisher.value = .loading(preview: sampleCharacter)
    do {
      try await fetchNextPage(fetchFromBeginning: true)
      uiStatePrivatePublisher.value = .finished(characters: self.characters)
    } catch {
      uiStatePrivatePublisher.value = .error(error: error)
    }
  }

  /// > Side effect: Updates ``listStatePublisher``.
  private func fetchMoreData() async {
    listStatePrivatePublisher.value = .loading
    do {
      try await fetchNextPage()
      listStatePrivatePublisher.value = .finished(characters: self.characters)
    } catch {
      listStatePrivatePublisher.value = .error(error: error)
    }
  }

  private func presentDetailView(id: String) {
    // for now navigate with segues.
//    print("TODO: present detail view")
  }
}

