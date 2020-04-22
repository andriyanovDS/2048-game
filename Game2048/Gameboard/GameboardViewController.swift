//
//  GameboardViewController.swift
//  Game2048
//
//  Created by Dmitry on 21.04.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import UIKit

class GameboardViewController: UIViewController {
  private let viewModel: GameboardViewModel
  private var gameboardView: GameboardView!
  private let cellWidth: CGFloat
  
  init(viewModel: GameboardViewModel) {
    self.viewModel = viewModel
    self.cellWidth = GameboardView.Constants.boardWidth / CGFloat(viewModel.size)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.viewModel.delegate = self
    }
  }
  
  private func setupView() {
    let view = GameboardView()
    let directions: [UISwipeGestureRecognizer.Direction] = [.up, .down, .left, .right]
    directions.forEach { direction in
      let swipeGestureRecognizer = UISwipeGestureRecognizer(
        target: self,
        action: #selector(handleSwipe(_:))
      )
      swipeGestureRecognizer.direction = direction
      swipeGestureRecognizer.numberOfTouchesRequired = 1
      view.boardView.addGestureRecognizer(swipeGestureRecognizer)
    }
    view.dataSource = self
    self.view = view
    gameboardView = view
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
}

extension GameboardViewController: GameboardViewDataSource {
  func numberOfRows() -> Int {
    viewModel.size
  }
}

extension GameboardViewController: GameboardViewModelDelegate {
  func onGameComplete(withResult result: GameResult) {
    
  }
  
  
  func viewModel(_: GameboardViewModel, insertCell cell: Board.Cell) {
    gameboardView.insertCell(withValue: cell.value, at: cell.position)
  }
  
  func viewModel(_: GameboardViewModel, cellPositionsDidChangeWithMovements movements: [Movement]) {
    let destructiveMovements = movements.filter { $0.isDestructive }
    let moveAnimator = UIViewPropertyAnimator(
      duration: 0.2,
      dampingRatio: 0.8,
      animations: {
        self.gameboardView.scoreValueLabel.text = String(self.viewModel.score)
        movements.forEach {
          self.gameboardView.moveCell(
            at: $0.from,
            to: $0.to,
            isDestructive: $0.isDestructive
          )
        }
      }
    )
    if destructiveMovements.count > 0 {
      moveAnimator.addCompletion { _ in
        destructiveMovements.forEach { movement in
          self.gameboardView.removeCell(at: movement.to)
          self.gameboardView.updateCellValue(
            self.viewModel.cellValue(at: movement.to),
            at: movement.to
          )
        }
      }
    }
    moveAnimator.startAnimation()
  }
}
