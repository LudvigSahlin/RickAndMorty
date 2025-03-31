//
//  CharactersViewController.swift
//  Rick
//
//  Created by Ludvig Hemma on 2025-03-29.
//

import UIKit
import SwiftUI

class CharactersViewController: UIViewController {

  private enum Constants {
    static let characterCellIdentifier = "characterCellIdentifier"
  }

  private lazy var charactersTableView: UITableView = {
    let tableView = UITableView()
    tableView.dataSource = self
//    tableView
    tableView.register(UITableViewCell.self,
                       forCellReuseIdentifier: Constants.characterCellIdentifier)
    return tableView
  }()

  private let viewModel = CharactersViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()

    addSubviews()
    setConstraints()


  }

  private func addSubviews() {
    view.addSubview(charactersTableView)
  }

  private func setConstraints() {
    charactersTableView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      charactersTableView.topAnchor.constraint(equalTo: view.topAnchor),
      charactersTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      charactersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      charactersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ])
  }

  


}

extension CharactersViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCell(withIdentifier: Constants.characterCellIdentifier)
    if cell == nil {
      cell = UITableViewCell(style: .subtitle,
                             reuseIdentifier: Constants.characterCellIdentifier)
    }


    let character = viewModel.rick





    var content = cell!.defaultContentConfiguration()
    // Configure content.
    content.image = UIImage(systemName: "dog")
    Task {
      let (data, _) = try await URLSession.shared.data(from: character.image)
      content.image = UIImage(data: data)
    }


    content.text = character.name
    content.secondaryText = character.status
    // Customize appearance.
    content.imageProperties.tintColor = .purple

    cell!.contentConfiguration = content




    return cell!
  }
}

#Preview {
  CharactersViewController()
}
