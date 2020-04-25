//
//  GameboardOfflineViewController.swift
//  Game2048
//
//  Created by Dmitry on 21.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import UIKit

class GameboardOfflineViewController: UIViewController {
  private let viewModel: GameboardOfflineViewModel
  private let router: GameboardRouter
  private let gameboardView: GameboardOfflineView
  private let configurator: GameboardViewConfigurator
  
  init(
    viewModel: GameboardOfflineViewModel,
    router: GameboardRouter,
    view: GameboardOfflineView,
    configurator: GameboardViewConfigurator
  ) {
    self.viewModel = viewModel
    self.router = router
    self.configurator = configurator
    self.gameboardView = view
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    router.controller = self

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.viewModel.viewDidLoad()
    }
  }
  
  private func setupView() {
    gameboardView.undoButton.addTarget(self, action: #selector(onPressUndoButton), for: .touchUpInside)
    gameboardView.restartButton.addTarget(self, action: #selector(onRestart), for: .touchUpInside)
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
      viewModel.moveLeft()
    case .right:
      viewModel.moveRight()
    case .up:
      viewModel.moveUp()
    case .down:
      viewModel.moveDown()
    default:
      print("Unknown direction \(recognizer.direction)")
    }
  }
  
  @objc private func onPressUndoButton() {
    viewModel.undo()
  }
  
  @objc private func onRestart() {
    gameboardView.boardView.clearCells(completion: {[weak self] in
      self?.viewModel.restart()
    })
  }
  
  private func handleFailedGameAlertResult(_ result: GameboardRouter.FailedGameAlertResult) {
    switch result {
    case .restart:
      onRestart()
    case .undoAction:
      viewModel.undo()
    }
  }
}

extension GameboardOfflineViewController: GameboardViewConfiguratorDelegate {
  func onGameComplete(withResult result: GameResult) {
    switch result {
    case .fail:
      router.openFailedGameAlert(complete: {[weak self] result in
        self?.handleFailedGameAlertResult(result)
      })
    case .win:
      return
    }
  }
}
