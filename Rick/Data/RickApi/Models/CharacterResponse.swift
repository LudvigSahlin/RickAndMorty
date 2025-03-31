//
//  CharacterResponse.swift
//  Rick
//
//  Created by Ludvig Hemma on 2025-03-31.
//

struct CharacterResponse: Decodable {
  let info: Info
  let results: [Character]
}
