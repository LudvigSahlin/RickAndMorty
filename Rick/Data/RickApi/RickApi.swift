//
//  RickApi.swift
//  Rick
//
//  Created by Ludvig Hemma on 2025-03-31.
//

import Foundation

protocol RickApiProtocol: Sendable {
  func fetchCharacters(page: Int) async throws(RickApiError) -> CharacterResponse
}

enum RickApiError: Error {
  case fetchError(_ error: Error)
  /// Request returned with a non success status code.
  case badResponse
}

final class RickApi: RickApiProtocol {

  private let baseUrl = URL(string: "https://rickandmortyapi.com/api")!

  func fetchCharacters(page: Int) async throws(RickApiError) -> CharacterResponse {
    do {
      let fetchUrl = baseUrl
        .appending(path: "character")
        .appending(queryItems: [URLQueryItem(name: "page", value: "\(page)")])
      let (data, response) = try await URLSession.shared.data(from: fetchUrl)

      guard let response = response as? HTTPURLResponse,
            200...299 ~= response.statusCode else {
        throw RickApiError.badResponse
      }

      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase

      let characterResponse = try decoder.decode(CharacterResponse.self, from: data)

      print("fetched characters, count: \(characterResponse.results.count).")
      return characterResponse

    } catch {
      throw RickApiError.fetchError(error)
    }
  }
}
