//
//  GameboardOnlineViewController.swift
//  Game2048
//
//  Created by Дмитрий Андриянов on 26.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import UIKit

class GameboardOnlineViewController: UIViewController {
  private let networkClient: GameboardNetworkClient
  private let gameboardView: GameboardOnlineView
  private let viewModel: GameboardViewModel
  private let configurator: GameboardViewConfigurator
  
  init(
    view: GameboardOnlineView,
    viewModel: GameboardViewModel,
    configurator: GameboardViewConfigurator,
    networkClient: GameboardNetworkClient
  ) {
    self.gameboardView = view
    self.viewModel = viewModel
    self.configurator = configurator
    self.networkClient = networkClient
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    networkClient.setupWebSocketClient()
    setupView()
  }
  
  private func setupView() {
    let directions: [UISwipeGestureRecognizer.Direction] = [.up, .down, .left, .right]
    directions.forEach { direction in
      let swipeGestureRecognizer = UISwipeGestureRecognizer(
        target: self,
        action: #selector(handleSwipe(_:))
      )
      swipeGestureRecognizer.direction = direction
      swipeGestureRecognizer.numberOfTouchesRequired = 1
      gameboardView.boardView.addGestureRecognizer(swipeGestureRecognizer)
    }
    
    gameboardView.viewDidLoad()
    self.view = gameboardView
  }
  
  @objc private func handleSwipe(_ recognizer: UISwipeGestureRecognizer) {
    guard recognizer.state == .ended else { return }
    switch recognizer.direction {
    case .left:
      networkClient.onUserAction(to: .left)
    case .right:
      networkClient.onUserAction(to: .right)
    case .up:
      networkClient.onUserAction(to: .up)
    case .down:
      networkClient.onUserAction(to: .down)
    default:
      print("Unknown direction \(recognizer.direction)")
    }
  }
}

extension GameboardOnlineViewController: GameboardViewConfiguratorDelegate {
  func onGameComplete(withResult result: GameResult) {
    
  }
}

extension GameboardOnlineViewController: GameboardNetworkClientDelegate {
  func networkClient(_: GameboardNetworkClient, didChangeOpponentState state: OpponentState) {
    let label = gameboardView.opponentStateValueLabel
    switch state {
    case .waiting:
      label.text = "Waiting for opponent..."
    case .connected(let isOpponentMove):
      label.text = "\(isOpponentMove ? "Opponent" : "Your") move"
    case .disconnected:
      label.text = "Opponent disconnected"
    }
  }
}
