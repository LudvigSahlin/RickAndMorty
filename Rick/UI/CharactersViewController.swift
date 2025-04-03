//
//  CharactersViewController.swift
//  Rick
//
//  Created by Ludvig Hemma on 2025-03-29.
//

import UIKit
import Combine
import SwiftUI

extension CharactersViewController {
  /// Main state of ViewController.
  enum UiState {
    case idle
    /// Initial data is being fetched.
    case loading(preview: Character)
    /// Initial data failed to fetch.
    case error(error: Error)
    /// Initial data is fetched.
    case finished(characters: [Character])

    fileprivate var showStateView: Bool {
      switch self {
      case .idle, .finished:
        return false
      case .loading, .error:
        return true
      }
    }
  }
  /// Typically used to show activity indicator in list.
  enum ListState {
    /// There might be more data to fetch.
    case idle
    /// More data is currently being fetched.
    case loading
    /// Last attempt to fetch more data resulted in an error.
    case error(error: Error)
    /// There is no more data available.
    case finished(characters: [Character])
  }
  /// User action.
  enum Action {
    /// Typically used if the first fetch fails.
    case refreshData
    case scrolledToBottom
    case tappedOnCharacter(id: String)
  }
}
class CharactersViewController: UIViewController {

  private enum Constants {
    static let characterCellIdentifier = "characterCellIdentifier"
    static let errorImage = UIImage(systemName: "exclamationmark.triangle")!
    static let loadingImage = UIImage(systemName: "arrowshape.down.circle")!
  }

  private lazy var stateView = StateView()

  private lazy var charactersTableView: UITableView = {
    let tableView = UITableView()
    tableView.dataSource = self
    tableView.delegate = self
    tableView.rowHeight = 116
    tableView.register(CharacterCell.self,
                       forCellReuseIdentifier: Constants.characterCellIdentifier)
    return tableView
  }()

  private let viewModel = CharactersViewModel()
  private var cancellables = Set<AnyCancellable>()
  private var characters: [Character] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    addSubviews()
    setConstraints()
    subscribeToPublishers()
    title = "Characters"
  }

  private func addSubviews() {
    view.addSubview(charactersTableView)
    view.addSubview(stateView)
  }

  private func setConstraints() {
    charactersTableView.translatesAutoresizingMaskIntoConstraints = false
    stateView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      charactersTableView.topAnchor.constraint(equalTo: view.topAnchor),
      charactersTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      charactersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      charactersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

      stateView.topAnchor.constraint(equalTo: view.topAnchor),
      stateView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      stateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      stateView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ])
  }

  private func subscribeToPublishers() {
    viewModel.uiStatePublisher
      .sink { [weak self] uiState in
        self?.handleUiState(uiState)
      }
      .store(in: &cancellables)

    viewModel.listStatePublisher
      .sink { [weak self] listState in
        self?.handleListState(listState)
      }
      .store(in: &cancellables)
  }

  private func handleUiState(_ uiState: UiState) {
    stateView.isHidden = !uiState.showStateView
    charactersTableView.isHidden = uiState.showStateView

    switch uiState {
    case .idle:
      break

    case .loading:
      stateView.imageView.image = Constants.loadingImage
      stateView.titleLabel.text = "Fetching characters . . ."
      stateView.subtitleLabel.text = ""

    case .error:
      stateView.imageView.image = Constants.errorImage
      stateView.titleLabel.text = "Something went wrong!"
      stateView.subtitleLabel.text = "Please check your internet connection."

    case .finished(let characters):
      self.characters = characters
      charactersTableView.reloadData()
    }
  }

  private func handleListState(_ listState: ListState) {
    switch listState {
    case .idle:
      break
    case .loading:
      // show loading spinner?
      break
    case .error:
      // remove loading spinner?
      break
    case .finished(let characters):
      self.characters = characters
      charactersTableView.reloadData() // TODO: append the new data only
      // remove loading spinner?
      break
    }
  }
}

extension CharactersViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let character = characters[indexPath.row]
    print("Selected character: \(character.name)")
    let id = "\(character.id)"
    viewModel.onAction(.tappedOnCharacter(id: id))
    tableView.deselectRow(at: indexPath, animated: true)


    let swiftUiView = CharacterDetailView(character: character)
    let hostingController = UIHostingController(rootView: swiftUiView)
    navigationController?.pushViewController(hostingController, animated: true)
  }
}

extension CharactersViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    characters.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row + 1 == characters.count {
      print("Scrolled to bottom")
      viewModel.onAction(.scrolledToBottom)
    }

    guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.characterCellIdentifier) as? CharacterCell else {
      print("could not reuse cell")
      return UITableViewCell()
    }
//    var cell = tableView.dequeueReusableCell(withIdentifier: Constants.characterCellIdentifier)
//    if cell == nil {
//      cell = UITableViewCell(style: .subtitle,
//                             reuseIdentifier: Constants.characterCellIdentifier)
//    }
    let character = characters[indexPath.row]
    cell.setContent(character)
    return cell
  }
}

actor ImageCache {
  static let shared = ImageCache()
  private let cache = NSCache<NSURL, NSData>()

  func load(url: URL) async throws -> Data {
    if let localImage = cache.object(forKey: url as NSURL) {
      print("Used cache data for image with url: \(url)")
      return localImage as Data
    }
    let (data, _) = try await URLSession.shared.data(from: url as URL)
    cache.setObject(data as NSData, forKey: url as NSURL)
    return data
  }
}

#Preview {
  CharactersViewController()
}
