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
  enum UiState: Equatable {
    case idle
    /// Initial data is being fetched.
    case loading(preview: Character)
    /// Initial data failed to fetch.
    case error
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
  enum ListState: Equatable {
    /// There might be more data to fetch.
    case idle
    /// More data is currently being fetched.
    case loading
    /// Last attempt to fetch more data resulted in an error.
    case error
    /// There is no more data available.
    case finished(characters: [Character])
  }
  /// User action.
  enum Action {
    /// User tapped on the try again button, visible when the ``UiState/error(:Error)`` is set.
    case errorStateButtonTapped
    case scrolledToBottom
    case tappedOnCharacter(id: String)
  }
}

/// Presents a list of characters.
class CharactersViewController: UIViewController {

  private enum Constants {
    static let characterCellIdentifier = "characterCellIdentifier"
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

  private lazy var listLoadingIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(style: .large)
    indicator.frame = CGRect(origin: .zero, size: CGSize(width: 100, height: 100))
    indicator.startAnimating()
    return indicator
  }()

  private let viewModel: CharactersViewModelProtocol
  private var cancellables = Set<AnyCancellable>()
  private var characters: [Character] = []

  /// Constructor typically used to mock view model states for previews.
  init(viewModel: CharactersViewModelProtocol) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    self.viewModel = CharactersViewModel()
    super.init(coder: coder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    addSubviews()
    setConstraints()
    subscribeToPublishers()
    title = "Characters"
    navigationItem.largeTitleDisplayMode = .always
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationController?.navigationBar.tintColor = .black
  }

  private func addSubviews() {
    view.addSubview(charactersTableView)
    view.addSubview(stateView)
    charactersTableView.tableFooterView = listLoadingIndicator
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
      stateView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
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
      stateView.setState(.loading(title: "Fetching characters . . ."))

    case .error:
      stateView.setState(.error(onTryAgainTapped: { [weak self] in
        self?.viewModel.onAction(.errorStateButtonTapped)
      }))

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
      listLoadingIndicator.startAnimating()

    case .error:
      listLoadingIndicator.stopAnimating()

    case .finished(let characters):
      if self.characters != characters {
        print("Received more characters, old count: \(self.characters.count), new: \(characters.count).")
        self.characters = characters
        charactersTableView.reloadData() // TODO: append the new data only
      } else {
        print("Received same characters, do not reload table.")
      }
      listLoadingIndicator.stopAnimating()
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
      print("Could not reuse cell")
      return UITableViewCell()
    }
    let character = characters[indexPath.row]
    cell.setSyncronousData(character)
    Task {
      if let image = await viewModel.fetchImage(character: character) {
        cell.setAsynconousData(image, id: character.id)
      }
    }
    return cell
  }
}

#if DEBUG

class CharactersViewModelMock: CharactersViewModelProtocol {
  var uiStateMockPublisher: CurrentValueSubject<CharactersViewController.UiState, Never> = .init(.idle)
  var uiStatePublisher: AnyPublisher<CharactersViewController.UiState, Never> {
    uiStateMockPublisher.eraseToAnyPublisher()
  }
  var listStateMockPublisher: CurrentValueSubject<CharactersViewController.ListState, Never> = .init(.idle)
  var listStatePublisher: AnyPublisher<CharactersViewController.ListState, Never> {
    listStateMockPublisher.eraseToAnyPublisher()
  }
  func onAction(_ action: CharactersViewController.Action) {}
  func fetchImage(character: Character) async -> UIImage? { UIImage(systemName: "wand") }
}

#Preview {
  let viewModel = CharactersViewModel()
  CharactersViewController(viewModel: viewModel)
}

#Preview("List loading") {
  let viewModel = CharactersViewModelMock()
  viewModel.uiStateMockPublisher.value = .finished(characters: [Character.sampleCharacter])
  viewModel.listStateMockPublisher.value = .loading
  return CharactersViewController(viewModel: viewModel)
}

#Preview("List error") {
  let viewModel = CharactersViewModelMock()
  viewModel.uiStateMockPublisher.value = .finished(characters: [Character.sampleCharacter])
  viewModel.listStateMockPublisher.value = .error
  return CharactersViewController(viewModel: viewModel)
}

#endif
