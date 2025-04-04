//
//  RickApi.swift
//  Rick
//
//  Created by Ludvig Hemma on 2025-03-31.
//

import Foundation

protocol RickApiProtocol: Sendable {
  func fetchCharacters(page: Int) async throws(RickApiError) -> CharacterResponse
  func fetchImage(url: URL) async throws(RickApiError) -> Data
}

enum RickApiError: Error {
  case fetchError(_ error: Error)
  /// Request returned with a non success status code.
  case badResponse
}

/// Responsible for handling versioning, urls and other details of the Rick and Morty API.
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
      return characterResponse

    } catch {
      throw RickApiError.fetchError(error)
    }
  }

  func fetchImage(url: URL) async throws(RickApiError) -> Data {
    do {
      let (data, response) = try await URLSession.shared.data(from: url)
      guard let response = response as? HTTPURLResponse,
            200...299 ~= response.statusCode else {
        throw RickApiError.badResponse
      }
      return data
    } catch {
      throw RickApiError.fetchError(error)
    }
  }
}
